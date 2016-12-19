FROM java:openjdk-8-jre-alpine
MAINTAINER Francesco Caliumi <francesco.caliumi@gmail.com>

ARG BK_VERSION=4.4.0
ARG BK_DIR=/opt/bookkeeper
ARG BK_JOURNAL_DIR=/data/journal
ARG BK_LEDGER_DIR=/data/ledger
ARG BK_INDEX_DIR=/data/index

ENV ZK_SERVERS=localhost:2181 \
    BK_PORT=3181 \
    BK_DOWNLOAD_DIR=https://archive.apache.org/dist/bookkeeper/bookkeeper-${BK_VERSION}/bookkeeper-server-${BK_VERSION}-bin.tar.gz \
    BOOKIE_OPTS=""

VOLUME ${BK_JOURNAL_DIR}
VOLUME ${BK_LEDGER_DIR}
VOLUME ${BK_INDEX_DIR}

COPY * /local/
RUN [ "/bin/sh", "/local/build.sh" ]

WORKDIR ${BK_DIR}

EXPOSE 3181/tcp

HEALTHCHECK --interval=3s --timeout=10s CMD /bin/bash /local/healthcheck.sh

ENTRYPOINT [ "/bin/bash", "/local/run.sh" ]
CMD []
