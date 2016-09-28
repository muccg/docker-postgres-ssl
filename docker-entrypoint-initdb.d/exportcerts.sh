#!/bin/bash

TMP_MOUNT=/tmpmount

cp /etc/ssl/certs/ssl-cert-snakeoil.pem $TMP_MOUNT/server.pem
cp /etc/ssl/private/ssl-cert-snakeoil.key $TMP_MOUNT/server.key