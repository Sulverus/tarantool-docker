#!/usr/bin/env tarantool

local fio = require('fio')
local errno = require('errno')
local fun = require('fun')
local urilib = require('uri')
local console = require('console')
local term = require('term')

local TARANTOOL_DEFAULT_PORT = 3301
local CONSOLE_SOCKET_PATH = 'unix/:/var/run/tarantool/tarantool.sock'

local orig_cfg = box.cfg

local function wrapper_cfg(override)
    cfg = {}
    cfg.slab_alloc_arena = tonumber(os.getenv('TARANTOOL_SLAB_ALLOC_ARENA')) or
        override.slab_alloc_arena
    cfg.slab_alloc_factor = tonumber(os.getenv('TARANTOOL_SLAB_ALLOC_FACTOR')) or
        override.slab_alloc_factor
    cfg.slab_alloc_maximal = tonumber(os.getenv('TARANTOOL_SLAB_ALLOC_MAXIMAL')) or
        override.slab_alloc_maximal
    cfg.slab_alloc_minimal = tonumber(os.getenv('TARANTOOL_SLAB_ALLOC_MINIMAL')) or
        override.slab_alloc_minimal
    cfg.listen = tonumber(os.getenv('TARANTOOL_PORT')) or
        override.listen or TARANTOOL_DEFAULT_PORT
    cfg.wal_mode = os.getenv('TARANTOOL_WAL_MODE') or
        override.wal_mode
    cfg.wal_dir = override.wal_dir or '/var/lib/tarantool'
    cfg.snap_dir = override.snap_dir or '/var/lib/tarantool'
    cfg.pid_file = override.pid_file or '/var/run/tarantool/tarantool.pid'

    local user_name = os.getenv('TARANTOOL_USER_NAME') or 'guest'
    local user_password = os.getenv('TARANTOOL_USER_PASSWORD')

    local work_dir = '/var/lib/tarantool'
    local snap_filename = "00000000000000000000.snap"
    local snap_path = work_dir..'/'..snap_filename

    local first_run = false

    if fio.stat(snap_path) == nil and errno() == errno.ENOENT then
        first_run = true
    end

    local replication_source = os.getenv('TARANTOOL_REPLICATION_SOURCE')
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

    if replication_source then
        cfg.replication_source = replication_source_table
    else
        cfg.replication_source = override.replication_source
    end

    orig_cfg(cfg)

    box.once('tarantool-entrypoint', function ()
        if first_run then
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
    end)

    console.listen(CONSOLE_SOCKET_PATH)

end

box.cfg = wrapper_cfg

-- re-run the script passed as parameter with all arguments that follow
execute_script = arg[1]
if execute_script == nil then
    box.cfg {}

    if term.isatty(io.stdout) then
        console.start()
        os.exit(0)
    end
else
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
