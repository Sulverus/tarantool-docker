FROM alpine:3.3

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN addgroup -S tarantool && adduser -S -G tarantool tarantool

# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION 1.7
ENV TARANTOOL_DOWNLOAD_URL https://github.com/tarantool/tarantool.git
ENV TARANTOOL_COMMIT f6e6918

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
        git \
        perl \
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
        libc-dev \
    && mkdir -p /usr/src/tarantool \
    && git clone $TARANTOOL_DOWNLOAD_URL /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout $TARANTOOL_COMMIT \
    && git -C /usr/src/tarantool submodule update \
    && echo "$TARANTOOL_VERSION" > /usr/src/tarantool/VERSION \
    && (cd /usr/src/tarantool; cmake .) \
    && make -C /usr/src/tarantool \
    && make -C /usr/src/tarantool install \
    && rm -r /usr/src/tarantool \
    && apk del .build-deps

RUN mkdir /data && chown tarantool:tarantool /data
VOLUME /var/lib/tarantool
WORKDIR /var/lib/tarantool

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3301
CMD [ "tarantool" ]
