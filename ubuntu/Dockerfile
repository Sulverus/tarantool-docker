FROM ubuntu:trusty
RUN apt-get update

# Add tarantool repo
RUN touch /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb http://download.tarantool.org/tarantool/1.6/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb-src http://download.tarantool.org/tarantool/1.6/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list

# Add GPG key
RUN apt-get install -y apt-transport-https && apt-get update
RUN apt-get install -y curl && curl http://download.tarantool.org/tarantool/1.6/gpgkey | sudo apt-key add -

# Install locales
ENV LC_ALL C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN apt-get install -y --force-yes tarantool tarantool-dev tarantool-expirationd tarantool-queue tarantool-http tarantool-connpool tarantool-shard tarantool-cbench tarantool-avro tarantool-pg tarantool-mysql tarantool-memcached
