FROM alpine:latest

ENV TIMEZONE=America/New_York \
    DEBUG_MODE=FALSE \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    CONTAINER_SCHEDULING_BACKEND=cron \
    CONTAINER_ENABLE_MESSAGING=FALSE \
    CONTAINER_MESSAGING_BACKEND=msmtp \
    CONTAINER_ENABLE_MONITORING=FALSE \
    CONTAINER_MONITORING_BACKEND=zabbix \
    CONTAINER_ENABLE_LOGSHIPPING=FALSE \
    S6_GLOBAL_PATH=/command:/usr/bin:/bin:/usr/sbin:sbin:/usr/local/bin:/usr/local/sbin \
    S6_KEEP_ENV=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \    
    IMAGE_NAME="m3hran/baseimage" \
    IMAGE_REPO_URL="https://github.com/m3hran/docker-baseimage"  

##
RUN set -ex && \
    apk update && \
    apk upgrade && \
    ### Add core utils
    apk add --no-cache \
        acl \
        bash \
        curl \
        gettext \
        git \
        grep \
        iputils \
        jq \
        less \
        logrotate \
        openssl \
        s6 \
        sudo \
        tzdata \
        vim \
        zstd \
    && \  
    \
    mv /usr/bin/envsubst /usr/local/bin/envsubst && \
    ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo ${TIMEZONE} > /etc/timezone && \
    \
    ## Quiet down sudo
    echo "Set disable_coredump false" > /etc/sudo.conf && \
    \  
    ### Clean up
    mkdir -p /etc/logrotate.d && \
    apk del --purge \
            gettext \
            && \
    rm -rf /etc/*.apk.new && \
    rm -rf /root/.cache && \
    rm -rf /tmp/* && \
    rm -rf /usr/src/* && \
    rm -rf /var/cache/apk/* && \ 
    \
    ### S6 overlay installation
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-noarch.tar.xz | tar xpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-x86_64.tar.xz | tar xpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-symlinks-noarch.tar.xz | tar xpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v3.2.0.2/s6-overlay-symlinks-arch.tar.xz | tar xpfJ - -C / && \
    mkdir -p /etc/cont-init.d && \
    mkdir -p /etc/cont-finish.d && \
    mkdir -p /etc/services.d && \
    chown -R 0755 /etc/cont-init.d && \
    chown -R 0755 /etc/cont-finish.d && \
    chmod -R 0755 /etc/services.d && \
    sed -i "s|echo|: # echo |g" /package/admin/s6-overlay/etc/s6-rc/scripts/cont-init && \
    sed -i "s|echo|: # echo |g" /package/admin/s6-overlay/etc/s6-rc/scripts/cont-finish && \
    sed -i "s|echo ' (no readiness notification)'|: # echo ' (no readiness notification)'|g" /package/admin/s6-overlay/etc/s6-rc/scripts/services-up && \
    sed -i "s|s6-echo -n|: # s6-echo -n|g" /package/admin/s6-overlay/etc/s6-rc/scripts/services-up && \
    sed -i "s|v=2|v=1|g" /package/admin/s6-overlay/etc/s6-linux-init/skel/rc.init && \
    sed -i "s|v=2|v=1|g" /package/admin/s6-overlay/etc/s6-linux-init/skel/rc.shutdown

### Set Shell to Bash
SHELL ["/bin/bash", "-c"]

### Entrypoint configuration
ENTRYPOINT ["/init"]

### Add folders
COPY install/ /

ARG  BUILD_DATE
LABEL org.opencontainers.image.created="${${no_value}BUILD_DATE}"
LABEL org.opencontainers.image.version="$IMG_VERSION"
LABEL org.opencontainers.image.title="$IMG_TITLE"
LABEL org.opencontainers.image.description="$IMG_DESC"
LABEL org.opencontainers.image.authors="$IMG_AUTHORS"
LABEL org.opencontainers.image.vendor="$IMG_VENDOR"
LABEL org.opencontainers.image.url="$IMG_URL"
