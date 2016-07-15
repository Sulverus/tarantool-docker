# What is Tarantool

Tarantool is a Lua application server integrated with a database management system. It has a "fiber" model which means that many Tarantool applications can run simultaneously on a single thread, while the Tarantool server itself can run multiple threads for input-output and background maintenance. It incorporates the LuaJIT -- "Just In Time" -- Lua compiler, Lua libraries for most common applications, and the Tarantool Database Server which is an established NoSQL DBMS. Thus Tarantool serves all the purposes that have made node.js and Twisted popular, plus it supports data persistence.

The database API allows for permanently storing Lua objects, managing object collections, creating or dropping secondary keys, making changes atomically, configuring and monitoring replication, performing controlled fail-over, and executing Lua code triggered by database events. Remote database instances are accessible transparently via a remote-procedure-invocation API.

For more information, please visit [tarantool.org](http://tarantool.org).

# How to use this image

## Start a Tarantool instance (without authentication)

```console
$ docker run --name some-tarantool -d tarantool/tarantool:1.7
```

Where `some-tarantool` is the name you want to assign to your container, and `1.7` is the tag specifying the Tarantool version you want. The `box.cfg{}` configuration manager is automatically called from the entry point, so your database will be ready to accept connections and serve data.

Note: this will create an instance without password protection and with an exposed 'guest' user, so anyone can directly connect to the container to change data in Tarantool. Please use this option only for development or testing.

## Start a Tarantool instance (with authentication)

```console
$ docker run --name some-tarantool -e TARANTOOL_USER_NAME=myusername -e TARANTOOL_USER_PASSWORD=mysecretpassword -d tarantool/tarantool:1.7
```

Where `some-tarantool` is the name you want to assign to your container, `myusername` is the name of the user that will be created and granted admin privileges, `mysecretpassword` is the password to be set for the user, and `1.7` is the tag specifying the Tarantool version you want. The `box.cfg{}` configuration manager is automatically called from the entry point, so your database will be ready to accept connections and serve data.

## Connect to Tarantool from an application in another Docker container

This image exposes the standard Tarantool port (3301), so container linking makes the Tarantool instance available to other application containers. Start your application container like this in order to link it to the Tarantool container:

```console
$ docker run --link some-tarantool:tarantool -d application-that-uses-tarantool
```

## Connect to Tarantool from the Tarantool command line client

```console
$ docker run -it --link some-tarantool:tarantool --rm tarantool/tarantool:1.7 tarantoolctl connect myusername:mysecretpassword@tarantool:3301
```

## Environment Variables

When you start the Tarantool image, you can adjust the configuration of the Tarantool instance by passing one or more environment variables on the `docker run` command line.

### `TARANTOOL_USER_NAME`

Setting this variable allows you to pick the name of the user that is utilized for remote connections. By default, it is 'guest'. Please note that since guest user in Tarantool can't have a password, it is highly recommended that you change it.

### `TARANTOOL_USER_PASSWORD`

For security reasons, it is recommended that you never leave this variable unset. This environment variable sets the user's password for Tarantool. In the above example, it is set to "mysecretpassword".

### `TARANTOOL_PORT`

Optional. Specifying this variable will tell Tarantool to listen for incoming connections on a specific port. Default is 3301.

### `TARANTOOL_REPLICATION_SOURCE`

Optional. Comma-separated list of URIs to treat as replication sources. Upon the start, Tarantool will attempt to connect to those instances, fetch the data snapshot and start replicating transaction logs. In other words, it will become a slave. For the multi-master configuration, other participating instances of Tarantool should be started with the same TARANTOOL_REPLICATION_SOURCE. (NB: applicable only to 1.7)

### `TARANTOOL_SLAB_ALLOC_ARENA`

Optional. Specifies how much memory Tarantool allocates to actually store tuples, in gigabytes. When the limit is reached, INSERT or UPDATE requests begin failing. Default is 1.0.

### `TARANTOOL_SLAB_ALLOC_FACTOR`

Optional. Used as the multiplier for computing the sizes of memory chunks that tuples are stored in. A lower value may result in less wasted memory depending on the total amount of memory available and the distribution of item sizes. Default is 1.1.

### `TARANTOOL_SLAB_ALLOC_MAXIMAL`

Optional. Size of the largest allocation unit in bytes. It can be increased if it is necessary to store large tuples. Default is 1048576.

### `TARANTOOL_SLAB_ALLOC_MINIMAL`

Optional. Size of the smallest allocation unit, in bytes. It can be decreased if most of the tuples are very small. Default is 16.

# Initializing a new instance

When a container is started for the first time, Tarantool entry point will call box.cfg{}, create users as necessary and expose the configured port.

# Adding application code in Lua

To add your application code written in Lua, you will need to inherit from one of the `tarantool` images and add your Lua code to /opt/tarantool:

```bash
FROM tarantool/tarantool:1.6
COPY app.lua /opt/tarantool
CMD ["tarantool", "/opt/tarantool/app.lua"]
```

# Running without a helper script

Sometimes you may want to run Tarantool completely on your own, instead of relying on the entrypoint script to call `box.cfg{}` for you. This may be the case when you have complex initialization logic, or packaging an existing application that you don't want to adapt to conventions of these Docker images.

Just replace `tarantool` with `/usr/local/bin/tarantool` in your Dockerfile:

```bash
FROM tarantool/tarantool:1.6
COPY app.lua /opt/tarantool
CMD ["/usr/local/bin/tarantool", "/opt/tarantool/app.lua"]
```

This will call Tarantool directly, sidestepping all entrypoint logic.
