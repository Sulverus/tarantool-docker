FROM ubuntu:trusty

# Add tarantool repo
RUN touch /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb http://tarantool.org/dist/master/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb-src http://tarantool.org/dist/master/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list

RUN apt-get update

# Install locales
ENV LC_ALL C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN apt-get install -y --force-yes tarantool tarantool-dev tarantool-expirationd tarantool-queue tarantool-http tarantool-shard
