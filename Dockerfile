FROM java:openjdk-8-jre-alpine
MAINTAINER Francesco Caliumi <francesco.caliumi@gmail.com>

ARG BK_VERSION=4.4.0

ENV ZK_SERVERS=localhost:2181 \
    BK_PORT=3181 \
    BK_DOWNLOAD_DIR=https://archive.apache.org/dist/bookkeeper/bookkeeper-${BK_VERSION}/bookkeeper-server-${BK_VERSION}-bin.tar.gz \
    BOOKIE_OPTS="" \
    BK_DIR=/opt/bookkeeper \
    BK_JOURNAL_DIR=/data/journal \
    BK_LEDGER_DIR=/data/ledger \
    BK_INDEX_DIR=/data/index

VOLUME ${BK_JOURNAL_DIR}
VOLUME ${BK_LEDGER_DIR}
VOLUME ${BK_INDEX_DIR}

COPY run.sh /local/

RUN set -x && \
	apk update && \
	apk add bash nano less wget tar grep netcat-openbsd && \
	mkdir -p /opt && \
	wget -q -O - ${BK_DOWNLOAD_DIR} | tar -xzf - -C /opt && \
	mv /opt/bookkeeper-server-${BK_VERSION} ${BK_DIR} && \
	rm -rf /var/cache/apk/*

WORKDIR ${BK_DIR}

EXPOSE 3181/tcp

HEALTHCHECK --interval=3s --timeout=60s CMD /bin/bash /local/healthcheck.sh

ENTRYPOINT [ "/bin/bash", "/local/run.sh" ]
CMD []
