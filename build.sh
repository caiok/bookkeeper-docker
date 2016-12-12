#!/bin/sh

# -------------- #
# Set bash to stop the script if a command terminates with an error
set -e
# Set bash to echo each command
set -x
# Set bash to stop if an unset variable is found
set -u
# -------------- #

# -------------- #
# Bash initialization
mkdir -p /etc/profile.d/
chmod a+rX /etc/profile.d/
ln -sv /local/bash_profile.sh /etc/profile.d/
# -------------- #

# -------------- #
. /etc/profile.d/bash_profile.sh
# -------------- #

# -------------- #
# Base installations
apk update
apk add bash nano less wget tar grep netcat-openbsd
# -------------- #

# -------------- #
# Bookkeeper download
mkdir -p /opt
wget -q -O - ${BK_DOWNLOAD_DIR} | tar -xzf - -C /opt
mv /opt/bookkeeper-server-${BK_VERSION} ${BK_DIR}
# -------------- #

# -------------- #
# Save ARG variables for using in run.sh and shells
cat << EOF > /local/env.sh
export BK_VERSION=${BK_VERSION}
export BK_DIR=${BK_DIR}
EOF
ln -sv /local/env.sh /etc/profile.d/
# -------------- #

# -------------- #
# Some housekeeping...
rm -rf /usr/share/man/*
rm -rf /usr/share/doc/*
find /usr/share/locale -mindepth 1 -maxdepth 1 | grep -v '/usr/share/locale/en' | xargs rm -rf
rm -rf /var/cache/apk/*
# -------------- #

# -------------- #
# Let's check that all is ok
java -version
# -------------- #
