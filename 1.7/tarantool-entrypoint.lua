#!/usr/bin/env tarantool

local slab_alloc_arena = os.getenv('TARANTOOL_SLAB_ALLOC_ARENA')
local admin_password = os.getenv('TARANTOOL_ADMIN_PASSWORD')
local listen_port = tonumber(os.getenv('TARANTOOL_PORT'))

if admin_password == nil then
    print("Error: password option is not specified: TARANTOOL_ADMIN_PASSWORD")
    os.exit(1)
end

if listen_port == nil then
    listen_port = 3301
end

if slab_alloc_arena == nil then
    slab_alloc_arena = 0.5
end

box.cfg {
    slab_alloc_arena = slab_alloc_arena;
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
