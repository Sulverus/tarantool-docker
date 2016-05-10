FROM centos

#Add tarantool repo
RUN touch /etc/yum.repos.d/tarantool.repo
RUN echo '[tarantool]' >> /etc/yum.repos.d/tarantool.repo 
RUN echo 'name=Centos-$releasever - Tarantool' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'baseurl=http://download.tarantool.org/tarantool/1.6/el/7/\$basearch/' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'enabled=1' >> /etc/yum.repos.d/tarantool.repo
RUN echo 'gpgcheck=0' >> /etc/yum.repos.d/tarantool.repo

# Reconfigure locales for C.UTF-8
RUN yum clean all
RUN localedef -f UTF-8 -i ru_RU C.UTF-8

EXPOSE 3301
# Install tarantool pack
RUN yum install -y tarantool tarantool-devel tarantool-expirationd tarantool-queue tarantool-http tarantool-pool tarantool-shard tarantool-connpool
