FROM java:openjdk-8-jre-alpine
MAINTAINER Francesco Caliumi <francesco.caliumi@gmail.com>

ARG BK_VERSION=4.4.0
ARG BK_DIR=/opt/bookkeeper
ARG BK_JOURNAL_DIR=/data/journal
ARG BK_LEDGER_DIR=/data/ledger
ARG BK_INDEX_DIR=/data/index
ARG BK_DOWNLOAD_DIR=https://archive.apache.org/dist/bookkeeper/bookkeeper-${BK_VERSION}/bookkeeper-server-${BK_VERSION}-bin.tar.gz

VOLUME /data

COPY * /local/
RUN [ "/bin/sh", "/local/build.sh" ]

WORKDIR /opt/bookkeeper

EXPOSE 3181/tcp

#HEALTHCHECK

ENTRYPOINT [ "/bin/bash", "/local/run.sh" ]
CMD []
