FROM fedora:21

# Add tarantool repo
RUN touch /etc/yum.repos.d/tarantool.repo
RUN echo '[tarantool_1_6]' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'name=Fedora-\$releasever - Tarantool' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'baseurl=http://download.tarantool.org/tarantool/1.6/fedora/22/\$basearch/' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'gpgcheck=0' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'enabled=1' >> /etc/yum.repos.d/tarantool.repo

# Add locale
RUN localedef -f UTF-8 -i ru_RU C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN yum clean all
RUN yum install -y tarantool tarantool-devel tarantool-expirationd tarantool-queue tarantool-http tarantool-connpool tarantool-shard tarantool-cbench tarantool-pg tarantool-mysql tarantool-memcached
