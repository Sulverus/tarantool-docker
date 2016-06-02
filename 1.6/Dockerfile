FROM alpine:3.3

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN addgroup -S tarantool && adduser -S -G tarantool tarantool

# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION 1.6.8.525
ENV TARANTOOL_DOWNLOAD_URL https://github.com/tarantool/tarantool/releases/download/1.6.8.525/tarantool-1.6.8.525.tar.gz
ENV TARANTOOL_DOWNLOAD_SHA1 7b451b8898b3022f37efba461048321f978b8587

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
    && (cd /usr/src/tarantool; cmake .) \
    && make -C /usr/src/tarantool \
    && make -C /usr/src/tarantool install \
    && rm -r /usr/src/tarantool \
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
