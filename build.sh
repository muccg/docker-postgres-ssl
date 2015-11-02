#!/bin/sh
#
# Script to build images
#

# break on error
set -e

REPO="muccg"
DATE=`date +%Y.%m.%d`

image="${REPO}/postgres-ssl"
version="9.4"
echo "################################################################### ${image}"
        
## warm up cache for CI
docker pull ${image} || true

## build
docker build --pull=true -t ${image}:${DATE} .
docker build -t ${image}:${version} .

## for logging in CI
docker inspect ${image}:${DATE}

# push
docker push ${image}:${DATE}
docker push ${image}:${version}
