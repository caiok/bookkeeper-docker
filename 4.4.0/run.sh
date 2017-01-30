#/bin/bash

# -------------- #
set -x -e -u
# -------------- #

echo "CIAO!"

# -------------- #
# Allow the container to be started with `--user`
if [ "$1" = 'bookkeeper' -a "$(id -u)" = '0' ]; then
    chown -R "$BK_USER" "${BK_DIR}" "${BK_JOURNAL_DIR}" "${BK_LEDGER_DIR}" "${BK_INDEX_DIR}"
    exec su-exec "$BK_USER" /bin/bash "$0" "$@"
fi
# -------------- #

# -------------- #
# Copy input config files in Bookkeeper configuration directory
cp -vaf /conf/* ${BK_DIR}/conf || true
chown -R "$BK_USER" ${BK_DIR}/conf

# Bookkeeper setup
sed -r -i.bak \
	-e "s|^zkServers.*=.*|zkServers=${ZK_SERVERS}|" \
	-e "s|^bookiePort.*=.*|bookiePort=${BK_PORT}|" \
	-e "s|^journalDirectory.*=.*|journalDirectory=${BK_JOURNAL_DIR}|" \
	-e "s|^ledgerDirectories.*=.*|ledgerDirectories=${BK_LEDGER_DIR}|" \
	-e "s|^[# ]*indexDirectories.*=.*|indexDirectories=${BK_INDEX_DIR}|" \
	-e "s|^[# ]*useHostNameAsBookieID.*=.*false|useHostNameAsBookieID=true|" \
	${BK_DIR}/conf/bk_server.conf
#diff ${BK_DIR}/conf/bk_server.conf.bak ${BK_DIR}/conf/bk_server.conf || true

#mkdir -pv ${BK_JOURNAL_DIR} ${BK_LEDGER_DIR} ${BK_INDEX_DIR}
# -------------- #

# -------------- #
# Wait for zookeeper server
#set +x
#zk_server1=$(echo ${ZK_SERVERS} | cut -d"," -f1)
#zk_server1_host=$(echo ${zk_server1} | cut -d":" -f1)
#zk_server1_port=$(echo ${zk_server1} | cut -d":" -f2)

#echo -en "\nWaiting for Zookeeper (${zk_server1_host}:${zk_server1_port})..."
#while [[ $(nc -z ${zk_server1_host} ${zk_server1_port}) -ne 0 ]] ; do
#	echo -n "."
#	sleep 2
#done
#echo " Connected!"
#set -x
# -------------- #

# -------------- #
# Initialize metadata on zookeeper if needed
#if [[ ! -z ${FORMAT_METADATA+x} && "${FORMAT_METADATA}" == "yes" ]]; then
#	/opt/bookkeeper/bin/bookkeeper shell metaformat -n -f
#fi
# -------------- #

# -------------- #
# Run command
#if [[ "$*" == "" ]]; then
#	${BK_DIR}/bin/bookkeeper bookie ${BOOKIE_OPTS}
#else
#	${BK_DIR}/bin/bookkeeper "$@"
#fi
exec "$@"
# -------------- #
