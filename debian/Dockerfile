FROM debian:jessie
RUN apt-get update

# Add tarantool repo
RUN touch /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb http://download.tarantool.org/tarantool/1.6/debian/ jessie main' >> /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb-src http://download.tarantool.org/tarantool/1.6/debian/ jessie main' >> /etc/apt/sources.list.d/tarantool.list

# Add GPG key
RUN apt-get install -y curl && curl http://download.tarantool.org/tarantool/1.6/gpgkey | apt-key add -
RUN apt-get install -y apt-transport-https && apt-get update 

# Install locales
RUN apt-get install -y locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN apt-get install -y --force-yes tarantool tarantool-dev tarantool-expirationd tarantool-queue tarantool-http tarantool-connpool tarantool-shard tarantool-cbench tarantool-avro tarantool-pg tarantool-mysql tarantool-memcached
