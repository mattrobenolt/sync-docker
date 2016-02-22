# BitTorrent Sync
#
# VERSION               0.1

FROM debian:jessie
MAINTAINER Bertrand Chazot <bertrand@bittorrent.com>
LABEL com.getsync.version="2.3.2"

RUN groupadd -r btsync && useradd -r -g btsync btsync

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

ENV SYNC_VERSION 2.3.2
ENV SYNC_DOWNLOAD_URL https://download-cdn.getsync.com/2.3.2/linux-x64/BitTorrent-Sync_x64.tar.gz
ENV SYNC_DOWNLOAD_SHA256 770cf326e42b1e7f478600f4a5868ba883f15c1dcdd1c308e7ddc2d99403d21d

RUN curl -sSL "$SYNC_DOWNLOAD_URL" -o sync.tar.gz \
    && echo "$SYNC_DOWNLOAD_SHA256 sync.tar.gz" | sha256sum -c - \
    && tar -xzf sync.tar.gz -C /usr/local/bin btsync \
    && rm sync.tar.gz

RUN mkdir -p /data && chown btsync:btsync /data
VOLUME /data/sync
WORKDIR /data

COPY btsync.conf /etc/
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8888
EXPOSE 5555
EXPOSE 5555/udp

CMD [ "--log", "--config", "/etc/btsync.conf" ]
