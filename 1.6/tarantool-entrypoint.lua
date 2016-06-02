#!/usr/bin/env tarantool

local slab_alloc_arena = os.getenv('TARANTOOL_SLAB_ALLOC_ARENA')
local slab_alloc_factor = os.getenv('TARANTOOL_SLAB_ALLOC_FACTOR')
local slab_alloc_maximal = os.getenv('TARANTOOL_SLAB_ALLOC_MAXIMAL')
local slab_alloc_minimal = os.getenv('TARANTOOL_SLAB_ALLOC_MINIMAL')
local admin_password = os.getenv('TARANTOOL_ADMIN_PASSWORD')
local listen_port = tonumber(os.getenv('TARANTOOL_PORT'))

if admin_password == nil then
    admin_password = ""

    warn_str = [[****************************************************
WARNING: No password has been set for the database.
         This will allow anyone with access to the
         Tarantool port to access your database. In
         Docker's default configuration, this is
         effectively any other container on the same
         system.
         Use "-e TARANTOOL_ADMIN_PASSWORD=password"
         to set it in "docker run".
****************************************************]]
    print(warn_str)
end

if listen_port == nil then
    listen_port = 3301
end

if slab_alloc_arena == nil then
    slab_alloc_arena = 0.5
end

if slab_alloc_factor == nil then
    slab_alloc_factor = 1.1
end

if slab_alloc_maximal == nil then
    slab_alloc_maximal = 1048576
end

if slab_alloc_minimal == nil then
    slab_alloc_minimal = 16
end

box.cfg {
    slab_alloc_arena = slab_alloc_arena;
    slab_alloc_factor = slab_alloc_factor;
    slab_alloc_maximal = slab_alloc_maximal;
    slab_alloc_minimal = slab_alloc_minimal;
    wal_mode = 'write';
    listen = listen_port;
    work_dir = '/var/lib/tarantool';
}

box.schema.user.passwd("admin", admin_password)

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
