#!/bin/bash

# create self signed cert
cd $PGDATA
openssl req -new -newkey rsa:1024 -days 365000 -nodes -x509 -keyout server.key -subj "/CN=PostgreSQL" -out server.crt
chmod og-rwx server.key
chown -R postgres:postgres $PGDATA

# turn on ssl
sed -ri "s/^#?(ssl\s*=\s*)\S+/\1'on'/" "$PGDATA/postgresql.conf"
