#/bin/bash

# -------------- #
set -x -e -u
# -------------- #

# -------------- #
# Load build time arguments
source /local/env.sh
# -------------- #

# -------------- #
# Bookkeeper setup
sed -r -i.bak \
	-e "s|^zkServers.*=.*|zkServers=${ZK_SERVERS}|" \
	-e "s|^bookiePort.*=.*|bookiePort=${BK_PORT}|" \
	-e "s|^journalDirectory.*=.*|journalDirectory=${BK_JOURNAL_DIR}|" \
	-e "s|^ledgerDirectories.*=.*|ledgerDirectories=${BK_LEDGER_DIR}|" \
	-e "s|^[# ]*indexDirectories.*=.*|indexDirectories=${BK_INDEX_DIR}|" \
	-e "s|^[# ]*useHostNameAsBookieID.*=.*false|useHostNameAsBookieID=true|" \
	${BK_DIR}/conf/bk_server.conf
diff ${BK_DIR}/conf/bk_server.conf.bak ${BK_DIR}/conf/bk_server.conf || true

mkdir -pv ${BK_JOURNAL_DIR} ${BK_LEDGER_DIR} ${BK_INDEX_DIR}
# -------------- #

# -------------- #
# Save ENV variables for using in shells
cat << EOF >> /local/env.sh
export BK_PORT=${BK_PORT}
export BK_JOURNAL_DIR=${BK_JOURNAL_DIR}
export BK_LEDGER_DIR=${BK_LEDGER_DIR}
export BK_INDEX_DIR=${BK_INDEX_DIR}
EOF
# -------------- #

# -------------- #
# Wait for zookeeper server
set +x
zk_server1=$(echo ${ZK_SERVERS} | cut -d"," -f1)
zk_server1_host=$(echo ${zk_server1} | cut -d":" -f1)
zk_server1_port=$(echo ${zk_server1} | cut -d":" -f2)

echo -en "\nWaiting for Zookeeper..."
while [[ "$(nc -z ${zk_server1_host} ${zk_server1_port})" != "0" ]] ; do
	echo -n "."
	sleep 2
done
echo " Connected!"
set -x
# -------------- #

# -------------- #
# Run bookie
${BK_DIR}/bin/bookkeeper bookie
# -------------- #
