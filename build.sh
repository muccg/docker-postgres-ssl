#!/bin/sh
#
# Script to build images
#

# break on error
set -e
set -x
set -a
: ${DOCKER_USE_HUB:="0"}

DATE=`date +%Y.%m.%d`


ci_docker_login() {
    docker login -u ${DOCKER_USERNAME} --password="${DOCKER_PASSWORD}"
}


version="9.4"
image="muccg/postgres-ssl:${version}"
echo "################################################################### ${image}"

## warm up cache for CI
docker pull ${image} || true

## build
docker build --pull=true -t ${image}-${DATE} .
docker build -t ${image} .

## for logging in CI
docker inspect ${image}-${DATE}

# push
if [ ${DOCKER_USE_HUB} = "1" ]; then
    ci_docker_login
    docker push ${image}-${DATE}
    docker push ${image}
fi
