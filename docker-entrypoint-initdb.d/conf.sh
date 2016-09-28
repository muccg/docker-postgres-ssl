#!/bin/bash

cp /docker-entrypoint-initdb.d/postgresql.conf $PGDATA/postgresql.conf
cp /docker-entrypoint-initdb.d/pg_hba.conf $PGDATA/pg_hba.conf

chown -R postgres:postgres $PGDATA