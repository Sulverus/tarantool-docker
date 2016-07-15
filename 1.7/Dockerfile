FROM alpine:3.4
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION=1.7 \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_COMMIT=b4a4139 \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    LUAROCKS_URL=http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz

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
        lua \
        curl \
        lua-dev \
        musl-dev \
        make \
        git \
        gcc \
        tar \
        zip \
    && apk add --no-cache --virtual .build-deps \
        perl \
        g++ \
        cmake \
        readline-dev \
        openssl-dev \
        yaml-dev \
        lz4-dev \
        binutils-dev \
        ncurses-dev \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout "$TARANTOOL_COMMIT" \
    && git -C /usr/src/tarantool submodule update \
    && echo "$TARANTOOL_VERSION" > /usr/src/tarantool/VERSION \
    && (cd /usr/src/tarantool; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             .) \
    && make -C /usr/src/tarantool -j\
    && make -C /usr/src/tarantool install \
    && : "---------- small ----------" \
    && (cd /usr/src/tarantool/src/lib/small; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/small \
    && make -C /usr/src/tarantool/src/lib/small install \
    && : "---------- msgpuck ----------" \
    && (cd /usr/src/tarantool/src/lib/msgpuck; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/msgpuck \
    && make -C /usr/src/tarantool/src/lib/msgpuck install \
    && : "---------- luarocks ----------" \
    && wget -O luarocks.tar.gz "$LUAROCKS_URL" \
    && mkdir -p /usr/src/luarocks \
    && tar -xzf luarocks.tar.gz -C /usr/src/luarocks --strip-components=1 \
    && (cd /usr/src/luarocks; \
        ./configure; \
        make build; \
        make install) \
    && rm -r /usr/src/luarocks \
    && apk del .build-deps

COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        mariadb-client-libs \
        libpq \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        coreutils \
        gcc \
        g++ \
        postgresql-dev \
    && : "---------- luarocks ----------" \
    && luarocks install avro-schema \
    && luarocks install expirationd \
    && luarocks install queue \
    && luarocks install connpool \
    && luarocks install shard \
    && luarocks install http \
    && luarocks install pg \
    && luarocks install mysql \
    && luarocks install memcached \
    && luarocks install lua-term \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps


RUN mkdir -p /var/lib/tarantool \
    && chown tarantool:tarantool /var/lib/tarantool \
    && mkdir -p /opt/tarantool \
    && chown tarantool:tarantool /opt/tarantool \
    && mkdir -p /var/run/tarantool \
    && chown tarantool:tarantool /var/run/tarantool

VOLUME /var/lib/tarantool
VOLUME /opt/tarantool
WORKDIR /opt/tarantool

COPY tarantool-entrypoint.lua /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3301
CMD [ "tarantool" ]
