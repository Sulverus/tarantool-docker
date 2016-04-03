FROM fedora:21

# Add tarantool repo
RUN touch /etc/yum.repos.d/tarantool.repo
RUN echo '[tarantool]' >> /etc/yum.repos.d/tarantool.repo 
RUN echo 'name=Centos-$releasever - Tarantool' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'baseurl=http://tarantool.org/dist/1.6/fedora/$releasever/$basearch/' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'enabled=1' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'gpgcheck=0' >> /etc/yum.repos.d/tarantool.repo

# Add locale
RUN localedef -f UTF-8 -i ru_RU C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN yum clean all
RUN yum install -y tarantool tarantool-dev tarantool-modules tarantool-expirationd tarantool-queue tarantool-http tarantool-pool tarantool-shard
