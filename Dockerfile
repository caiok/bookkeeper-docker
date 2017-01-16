FROM java:openjdk-8-jre-alpine
MAINTAINER Francesco Caliumi <francesco.caliumi@gmail.com>

# Install required packages
RUN apk add --no-cache \
    bash \
    su-exec

ENV ZK_SERVERS=localhost:2181 \
    BK_USER=bookkeeper \
    BK_PORT=3181 \
    BOOKIE_OPTS="" \
    BK_JOURNAL_DIR=/data/journal \
    BK_LEDGER_DIR=/data/ledger \
    BK_INDEX_DIR=/data/index

# Add a user and make dirs
RUN set -x \
    && adduser -D "${BK_USER}" \
    && mkdir -p "${BK_JOURNAL_DIR}" "${BK_LEDGER_DIR}" "${BK_INDEX_DIR}" \
    && chown "$BK_USER:$BK_USER" "${BK_JOURNAL_DIR}" "${BK_LEDGER_DIR}" "${BK_INDEX_DIR}"

#ARG BK_VERSION=4.4.0
#ARG BK_VERSION_SHA=85b8dc9053bf6805ea81e60b6eebc521eabb4cc7

ARG GPG_KEY=D0BC8D8A4E90A40AFDFC43B3E22A746A68E327C1
ARG BK_VERSION=4.4.0

ENV DISTRO_NAME=bookkeeper-server-${BK_VERSION}-bin

#RUN set -x \
#	&& apk add --no-cache --virtual .build-deps \
#		gnupg \
#		tar \
#		wget \
#	&& mkdir -p /opt \
#	&& wget -q -O - ${BK_DOWNLOAD_DIR} | tar -xzf - -C /opt \
#	&& mv /opt/bookkeeper-server-${BK_VERSION} ${BK_DIR} \
#	&& apk del .build-deps \
#	&& rm -rf /var/cache/apk/*
	
# Download Apache Bookkeeper, verify its PGP signature, untar and clean up
RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        gnupg \
        wget \
    && mkdir -pv /opt \
    && cd /opt \
    && wget -q "https://archive.apache.org/dist/bookkeeper/bookkeeper-${BK_VERSION}/${DISTRO_NAME}.tar.gz" \
    && wget -q "https://archive.apache.org/dist/bookkeeper/bookkeeper-${BK_VERSION}/${DISTRO_NAME}.tar.gz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
#    && gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" \
#    && gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz" \
    && tar -xzf "$DISTRO_NAME.tar.gz" \
    && rm -r "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc" \
    && apk del .build-deps

ENV BK_DIR=/opt/bookkeeper-server-${BK_VERSION}
ENV PATH=$PATH:${BK_DIR}/bin

WORKDIR ${BK_DIR}
VOLUME ["${BK_JOURNAL_DIR}", "${BK_LEDGER_DIR}", "${BK_INDEX_DIR}"]

EXPOSE ${BK_PORT}/tcp

COPY run.sh healthcheck.sh /opt/

ENTRYPOINT [ "/bin/bash", "/opt/run.sh" ]
CMD ["bookkeeper", "bookie"]

HEALTHCHECK --interval=3s --timeout=60s CMD /bin/bash /opt/healthcheck.sh
