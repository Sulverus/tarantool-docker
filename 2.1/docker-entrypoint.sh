#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1:0:1}" = '-' ]; then
    set -- tarantool "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'tarantool' -a "$(id -u)" = '0' ]; then
    chown -R tarantool /var/lib/tarantool
    exec su-exec tarantool "$0" "$@"
fi

# entry point wraps the passed script to do basic setup
if [ "$1" = 'tarantool' ]; then
    shift
    exec tarantool "/usr/local/bin/tarantool-entrypoint.lua" "$@"
fi

exec "$@"
