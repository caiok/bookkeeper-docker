#/bin/bash

set -x
set -e

source /local/env.sh

if [[ "${ZK_SERVERS}" != "" ]]
then
	sed -ri "s|^zkServers=.*|zkServers=${ZK_SERVERS}|" ${BK_DIR}/conf/bk_server.conf
	diff ${BK_DIR}/conf/bk_server.conf.bak ${BK_DIR}/conf/bk_server.conf || true
fi

mkdir -p ${BK_JOURNAL_DIR} ${BK_LEDGER_DIR} ${BK_INDEX_DIR}

${BK_DIR}/bin/bookkeeper localbookie 5
