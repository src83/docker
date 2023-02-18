#!/bin/bash

# Create SQL Dump file
mysqldump --single-transaction -u "$MYSQL_USER" -h "$HOSTNAME" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > /var/backups/dump/"$(date '+%Y-%m-%d_%H:%M:%S')__dump.sql" 2> /dev/null

cd /var/backups || exit

# Permissions and Ownership correction
chmod 666 dump/* && chown 1000.1000 dump/*

# Create an Archive from SQL Dump file
tar cvf dump.tar dump > /dev/null
gzip -c dump.tar > "$(date '+%Y-%m-%d_%H:%M:%S')__dump.tar.gz"

# Save archive && remove the stuff
mv ./*__dump.tar.gz archives
rm dump.tar
rm dump/*

# Permissions and Ownership correction
chmod 666 archives/* && chown 1000.1000 archives/*
