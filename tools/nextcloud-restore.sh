#!/bin/bash
#
# This script will restore the backup made during an installation
source /etc/mailinabox.conf # load global vars

if [ -z "$1" ]; then
	echo "Usage: nextcloud-restore.sh <backup directory>"
	echo
	echo "WARNING: This will restore the database to the point of the installation!"
	echo "         This means that you will lose all changes made by users after that point"
	echo
	echo
	echo "Backups are stored here: $STORAGE_ROOT/nextcloud-backup/"
	echo
	echo "Available backups:"
	echo
	find $STORAGE_ROOT/nextcloud-backup/* -maxdepth 0 -type d
	echo
	echo "Supply the directory that was created during the last installation as the only commandline argument"
	exit
fi

if [ ! -f $1/config.php ]; then
	echo "This isn't a valid backup location"
	exit
fi

echo "Restoring backup from $1"
service php7.0-fpm stop

# remove the current ownCloud/Nextcloud installation
rm -rf /usr/local/lib/nextcloud/
# restore the current ownCloud/Nextcloud application
cp -r  "$1/nextcloud-install" /usr/local/lib/nextcloud

# restore access rights
chmod 750 /usr/local/lib/nextcloud/{apps,config}

cp "$1/nextcloud.db" $STORAGE_ROOT/nextcloud/
cp "$1/config.php" $STORAGE_ROOT/nextcloud/

ln -sf $STORAGE_ROOT/nextcloud/config.php /usr/local/lib/nextcloud/config/config.php
chown -f -R www-data.www-data $STORAGE_ROOT/nextcloud /usr/local/lib/nextcloud
chown www-data.www-data $STORAGE_ROOT/nextcloud/config.php

sudo -u www-data php /usr/local/lib/nextcloud/occ maintenance:mode --off

service php7.0-fpm start
echo "Done"
