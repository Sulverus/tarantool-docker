#!/usr/bin/env tarantool

local fio = require('fio')
local errno = require('errno')
local fun = require('fun')
local urilib = require('uri')

local TARANTOOL_DEFAULT_PORT = 3301

local slab_alloc_arena = os.getenv('TARANTOOL_SLAB_ALLOC_ARENA') or 1.0
local slab_alloc_factor = os.getenv('TARANTOOL_SLAB_ALLOC_FACTOR') or 1.1
local slab_alloc_maximal = os.getenv('TARANTOOL_SLAB_ALLOC_MAXIMAL') or 1048576
local slab_alloc_minimal = os.getenv('TARANTOOL_SLAB_ALLOC_MINIMAL') or 16
local user_name = os.getenv('TARANTOOL_USER_NAME') or 'guest'
local user_password = os.getenv('TARANTOOL_USER_PASSWORD')
local listen_port = tonumber(os.getenv('TARANTOOL_PORT')) or TARANTOOL_DEFAULT_PORT
local replication_source = os.getenv('TARANTOOL_REPLICATION_SOURCE')
local wal_mode = os.getenv('TARANTOOL_WAL_MODE') or 'write'

local work_dir = '/var/lib/tarantool'
local snap_filename = "00000000000000000000.snap"
local snap_path = work_dir..'/'..snap_filename

local first_run = false

if fio.stat(snap_path) == nil and errno() == errno.ENOENT then
    first_run = true
end

local replication_source_table = {}
if replication_source ~= nil then
    for uri in string.gmatch(replication_source, "[^,]+") do

        local parsed_uri = urilib.parse(uri)
        if parsed_uri == nil then
            error("Incorrect replication source URI format: '"..uri.."'")
        end
        local host = parsed_uri.host
        local port = parsed_uri.service or TARANTOOL_DEFAULT_PORT
        local user = parsed_uri.login or user_name
        local password = parsed_uri.password or user_password

        if user == 'guest' then
            replication_source = string.format("%s:%s", host, port)
        elseif password == nil then
            replication_source = string.format("%s:@%s:%s", user, host, port)
        else
            replication_source = string.format("%s:%s@%s:%s", user, password,
                                               host, port)
        end

        table.insert(replication_source_table, replication_source)
    end
end



box.cfg {
    slab_alloc_arena = slab_alloc_arena;
    slab_alloc_factor = slab_alloc_factor;
    slab_alloc_maximal = slab_alloc_maximal;
    slab_alloc_minimal = slab_alloc_minimal;
    wal_mode = wal_mode;
    listen = listen_port;
    work_dir = work_dir;
    replication_source = replication_source_table;
}

local min_replica_uuid = nil
if box.info.replication.status ~= 'off' then
    local uuids
    uuids = fun.map(function(replica)
            return replica.uuid
                    end,
        box.info.replication):totable()

    table.sort(uuids)
    min_replica_uuid = uuids[1]
end

if first_run and (#box.info.replication == 0 or
                  box.info.server.uuid == min_replica_uuid) then

    print("Initializing database")

    if user_name ~= 'guest' and user_password == nil then
        user_password = ""

        warn_str = [[****************************************************
WARNING: No password has been set for the database.
         This will allow anyone with access to the
         Tarantool port to access your database. In
         Docker's default configuration, this is
         effectively any other container on the same
         system.
         Use "-e TARANTOOL_USER_PASSWORD=password"
         to set it in "docker run".
****************************************************]]
        print(warn_str)
    end

    if user_name == 'guest' and user_password == nil then
        warn_str = [[****************************************************
WARNING: 'guest' is chosen as primary user.
         Since it is not allowed to set a password for
         guest user, your instance will be accessible
         by anyone having direct access to the Tarantool
         port.
         If you wanted to create an authenticated user,
         specify "-e TARANTOOL_USER_NAME=username" and
         pick a user name other than "guest".
****************************************************]]
        print(warn_str)
    end

    if user_name == 'guest' and user_password ~= nil then
        user_password = nil

        warn_str = [[****************************************************
WARNING: A password for guest user has been specified.
         In Tarantool, guest user can't have a password
         and is always allowed to login, if it has
         enough privileges.
         If you wanted to create an authenticated user,
         specify "-e TARANTOOL_USER_NAME=username" and
         pick a user name other than "guest".
****************************************************]]
        print(warn_str)
    end

    if user_name ~= 'admin' and user_name ~= 'guest' then
        print(string.format("Creating user '%s'", user_name))
        box.schema.user.create(user_name)
    end

    if user_name ~= 'admin' then
        print(string.format("Granting admin privileges to user '%s'", user_name))
        box.schema.user.grant(user_name, 'read,write,execute', 'universe')
        box.schema.user.grant(user_name, 'replication')
    end

    if user_name ~= 'guest' then
        box.schema.user.passwd(user_name, user_password)
    end
end


-- re-run the script passed as parameter with all arguments that follow
execute_script = arg[1]
if execute_script ~= nil then
    narg = 0
    while true do
        arg[narg] = arg[narg + 1]
        if arg[narg] == nil then
            break
        end
        narg = narg + 1
    end

    dofile(execute_script)
end
