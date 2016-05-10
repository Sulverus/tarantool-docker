FROM ubuntu:trusty

# Add tarantool repo
RUN touch /etc/apt/sources.list.d/tarantool.list
RUN curl http://download.tarantool.org/tarantool/1.6/gpgkey | sudo apt-key add -
RUN echo 'deb http://download.tarantool.org/tarantool/1.6/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb-src http://download.tarantool.org/tarantool/1.6/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list

RUN apt-get update

# Install locales
ENV LC_ALL C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN apt-get install -y --force-yes tarantool tarantool-dev tarantool-expirationd tarantool-queue tarantool-http tarantool-pool tarantool-shard
