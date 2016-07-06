FROM alpine:3.4
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION=1.6.8.525 \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool/releases/download/1.6.8.525/tarantool-1.6.8.525.tar.gz \
    TARANTOOL_DOWNLOAD_SHA1=7b451b8898b3022f37efba461048321f978b8587 \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        libstdc++ \
        readline \
        openssl \
        yaml \
        lz4 \
        binutils \
        ncurses \
        libgomp \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
        cmake \
        make \
        tar \
        readline-dev \
        openssl-dev \
        yaml-dev \
        lz4-dev \
        binutils-dev \
        ncurses-dev \
    && wget -O tarantool.tar.gz "$TARANTOOL_DOWNLOAD_URL" \
    && echo "$TARANTOOL_DOWNLOAD_SHA1 *tarantool.tar.gz" | sha1sum -c - \
    && mkdir -p /usr/src/tarantool \
    && tar -xzf tarantool.tar.gz -C /usr/src/tarantool --strip-components=1 \
    && rm tarantool.tar.gz \
    && (cd /usr/src/tarantool; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             .) \
    && make -C /usr/src/tarantool -j \
    && make -C /usr/src/tarantool install \
    && rm -r /usr/src/tarantool \
    && apk del .build-deps


RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        mariadb-client-libs \
        libpq \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        gcc \
        g++ \
        postgresql-dev \
    && : "---------- expirationd ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/expirationd.git) \
    && cp -r /usr/src/expirationd/expirationd.lua "$TARANTOOL_INSTALL_LUADIR" \
    && rm -rf /usr/src/expirationd \
    && : "---------- queue ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/queue.git) \
    && mkdir -p "$TARANTOOL_INSTALL_LUADIR/queue/abstract/driver" \
    && cp -r /usr/src/queue/queue/*.lua "$TARANTOOL_INSTALL_LUADIR/queue" \
    && cp -r /usr/src/queue/queue/abstract/*.lua \
             "$TARANTOOL_INSTALL_LUADIR/queue/abstract" \
    && cp -r /usr/src/queue/queue/abstract/driver/*.lua \
             "$TARANTOOL_INSTALL_LUADIR/queue/abstract/driver" \
    && rm -rf /usr/src/queue \
    && : "---------- http ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/http.git) \
    && (cd /usr/src/http; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/http; make -j) \
    && (cd /usr/src/http; make install) \
    && rm -rf /usr/src/http \
    && : "---------- connpool ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/connpool.git) \
    && cp -r /usr/src/connpool/connpool.lua "$TARANTOOL_INSTALL_LUADIR" \
    && rm -rf /usr/src/connpool \
    && : "---------- shard ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/shard.git) \
    && cp -r /usr/src/shard/shard.lua "$TARANTOOL_INSTALL_LUADIR" \
    && rm -rf /usr/src/shard \
    && : "---------- msgpuck ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/msgpuck.git) \
    && (cd /usr/src/msgpuck; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/msgpuck; make -j) \
    && (cd /usr/src/msgpuck; make install) \
    && rm -rf /usr/src/cbench \
    && : "---------- cbench ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/cbench.git) \
    && (cd /usr/src/cbench; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/cbench; make -j) \
    && (cd /usr/src/cbench; make install) \
    && rm -rf /usr/src/cbench \
    && : "---------- avro ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/tarantool-avro.git) \
    && (cd /usr/src/tarantool-avro; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/tarantool-avro; make -j) \
    && (cd /usr/src/tarantool-avro; make install) \
    && rm -rf /usr/src/tarantool-avro \
    && : "---------- pg ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/pg.git) \
    && (cd /usr/src/pg; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/pg; make -j) \
    && (cd /usr/src/pg; make install) \
    && rm -rf /usr/src/pg \
    && : "---------- mysql ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/mysql.git) \
    && (cd /usr/src/mysql; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/mysql; make -j) \
    && (cd /usr/src/mysql; make install) \
    && rm -rf /usr/src/mysql \
    && : "---------- memcached ----------" \
    && (cd /usr/src; git clone https://github.com/tarantool/memcached.git) \
    && git -C /usr/src/memcached submodule update --init --recursive \
    && (cd /usr/src/memcached; cmake  -DCMAKE_BUILD_TYPE=RelWithDebInfo .) \
    && (cd /usr/src/memcached; make -j) \
    && (cd /usr/src/memcached; make install) \
    && rm -rf /usr/src/memcached \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps


RUN mkdir -p /var/lib/tarantool \
    && chown tarantool:tarantool /var/lib/tarantool \
    && mkdir -p /opt/tarantool \
    && chown tarantool:tarantool /opt/tarantool

VOLUME /var/lib/tarantool
VOLUME /opt/tarantool
WORKDIR /opt/tarantool

COPY tarantool-entrypoint.lua /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3301
CMD [ "tarantool" ]
