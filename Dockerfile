FROM phusion/baseimage
MAINTAINER Martin Taheri <m3hran@gmail.com>
LABEL Description="Docker Base Image"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV TZ America/New_York

RUN rm -f /etc/my_init.d/00_regen_ssh_host_keys.sh \
    && apt-get autoremove -y --purge openssh-server openssh-sftp-server \
    && echo 'export TERM=xterm' >> /root/.bashrc

COPY bin/clean_install.sh /usr/local/bin/clean_install.sh

# Install packages
RUN apt-get -q update \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN clean_install.sh --no-install-recommends \
    curl wget git tzdata\
    zip unzip \
    nano vim \
    htop openssh-client \
    gettext

WORKDIR /u/apps
