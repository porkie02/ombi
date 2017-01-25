#!/usr/bin/env bash

# Check our uid/gid, change if env variables require it
if [ "$( id -u ombi )" -ne "${LUID}" ]; then
    usermod -o -u ${LUID} ombi
fi

if [ "$( id -g ombi )" -ne "${LGID}" ]; then
    groupmod -o -g ${LGID} ombi
fi

# Borrowed from
# https://github.com/rogueosb/docker-plexrequestsnet/blob/master/start.sh
if [ ! -f /config/Ombi.sqlite ]; then
    if [ -f /config/PlexRequests.sqlite ]; then
        mv /config/PlexRequests.sqlite /config/Ombi.sqlite
    else
        sqlite3 Ombi.sqlite "create table aTable(field1 int); drop table aTable;" # create empty db
    fi
fi

# check for Backups folder in config
if [ ! -d /config/Backup ]; then
  echo "Creating Backup dir..."
  mkdir /config/Backup
fi


ln -s /config/Ombi.sqlite /opt/Ombi/Release/Ombi.sqlite
ln -s /config/Backup /opt/Ombi/Release/Backup

# Set permissions
chown -R ombi:ombi /config/ /opt/Ombi

exec runuser -l ombi -c '/usr/bin/mono /opt/Ombi/Release/Ombi.exe'
