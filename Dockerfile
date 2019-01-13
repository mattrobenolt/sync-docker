FROM debian:stretch-slim

RUN groupadd -r rslsync && useradd -r -g rslsync rslsync

# grab gosu for easy step-down from root
RUN set -ex \
    && GOSU_VERSION=1.11 \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg \
        dirmngr \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && for key in \
      B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    ; do \
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && gpgconf --kill all \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove \
        ca-certificates \
        wget \
        gnupg \
        dirmngr \
    && chmod +x /usr/local/bin/gosu

ENV SYNC_VERSION 2.6.2
ENV SYNC_DOWNLOAD_URL https://download-cdn.resilio.com/2.6.2/linux-x64/resilio-sync_x64.tar.gz
ENV SYNC_DOWNLOAD_SHA256 82f940a130a0e82c3b020dd9cb1381ae0c0f2b52dee1b7eff81f90b3c997086f

RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O sync.tar.gz "$SYNC_DOWNLOAD_URL" \
    && echo "$SYNC_DOWNLOAD_SHA256 sync.tar.gz" | sha256sum -c - \
    && tar -xzf sync.tar.gz -C /usr/local/bin rslsync \
    && rm sync.tar.gz \
    && apt-get purge -y --auto-remove ca-certificates wget

RUN mkdir -p /data && chown rslsync:rslsync /data
VOLUME /data/sync
WORKDIR /data

COPY rslsync.conf /etc/
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8888
EXPOSE 5555
EXPOSE 5555/udp

CMD [ "--log", "--config", "/etc/rslsync.conf" ]
