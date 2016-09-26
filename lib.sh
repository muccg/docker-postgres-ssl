#!/bin/sh
#
# common definitons shared between projects
#
set -a

TOPDIR=$(cd `dirname $0`; pwd)
DATE=`date +%Y.%m.%d`

: ${DOCKER_BUILD_PROXY:="--build-arg http_proxy"}
: ${DOCKER_USE_HUB:="0"}
: ${DOCKER_IMAGE:="muccg/${PROJECT_NAME}"}
: ${SET_HTTP_PROXY:="1"}
: ${DOCKER_NO_CACHE:="0"}
: ${DOCKER_PULL:="1"}

# Do not set these, they are vars used below
DOCKER_ROUTE=''
DOCKER_BUILD_OPTS=''
DOCKER_RUN_OPTS=''
DOCKER_COMPOSE_BUILD_OPTS=''

usage() {
    echo ""
    echo "Environment:"
    echo " Pull during build              DOCKER_PULL                 ${DOCKER_PULL} "
    echo " No cache during build          DOCKER_NO_CACHE             ${DOCKER_NO_CACHE} "
    echo " Use proxy during builds        DOCKER_BUILD_PROXY          ${DOCKER_BUILD_PROXY}"
    echo " Push/pull from docker hub      DOCKER_USE_HUB              ${DOCKER_USE_HUB}"
    echo " Release docker image           DOCKER_IMAGE                ${DOCKER_IMAGE}"
    echo " Use a http proxy               SET_HTTP_PROXY              ${SET_HTTP_PROXY}"
    echo ""
    echo "Usage:"
    echo " ./develop.sh (build)"
    echo " ./develop.sh (publish_docker_image)"
    echo " ./develop.sh (ci_docker_login)"
    echo ""
    echo "Example, start dev with no proxy and rebuild everything:"
    echo "SET_HTTP_PROXY=0 ./develop.sh build"
    echo ""
    exit 1
}


info () {
  printf "\r  [ \033[00;34mINFO\033[0m ] $1\n"
}


success () {
  printf "\r\033[2K  [ \033[00;32m OK \033[0m ] $1\n"
}


fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit 1
}


docker_options() {
    DOCKER_ROUTE=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
    success "Docker ip ${DOCKER_ROUTE}"

    _http_proxy

    if [ ${DOCKER_PULL} = "1" ]; then
         DOCKER_BUILD_PULL="--pull=true"
         DOCKER_COMPOSE_BUILD_PULL="--pull"
    else
         DOCKER_BUILD_PULL="--pull=false"
         DOCKER_COMPOSE_BUILD_PULL=""
    fi

    if [ ${DOCKER_NO_CACHE} = "1" ]; then
         DOCKER_BUILD_NOCACHE="--no-cache=true"
         DOCKER_COMPOSE_BUILD_NOCACHE="--no-cache"
    else
         DOCKER_BUILD_NOCACHE="--no-cache=false"
         DOCKER_COMPOSE_BUILD_NOCACHE=""
    fi

    DOCKER_BUILD_OPTS="${DOCKER_BUILD_OPTS} ${DOCKER_BUILD_NOCACHE} ${DOCKER_BUILD_PROXY} ${DOCKER_BUILD_PULL}"
    DOCKER_COMPOSE_BUILD_OPTS="${DOCKER_COMPOSE_BUILD_OPTS} ${DOCKER_COMPOSE_BUILD_NOCACHE} ${DOCKER_COMPOSE_BUILD_PULL}"
}


_http_proxy() {
    info 'http proxy'

    if [ ${SET_HTTP_PROXY} = "1" ]; then
        if [ -z ${HTTP_PROXY_HOST+x} ]; then
            HTTP_PROXY_HOST=${DOCKER_ROUTE}
        fi
        http_proxy="http://${HTTP_PROXY_HOST}:3128"
        HTTP_PROXY="http://${HTTP_PROXY_HOST}:3128"
        NO_PROXY=${HTTP_PROXY_HOST}
        no_proxy=${HTTP_PROXY_HOST}
        success "Proxy $http_proxy"
    else
        info 'Not setting http_proxy'
    fi

    export HTTP_PROXY http_proxy NO_PROXY no_proxy

    success "HTTP proxy ${HTTP_PROXY}"
}


ci_docker_login() {
    info 'Docker login'

    if [ -z ${DOCKER_USERNAME+x} ]; then
        DOCKER_USERNAME=${bamboo_DOCKER_USERNAME}
    fi
    if [ -z ${DOCKER_PASSWORD+x} ]; then
        DOCKER_PASSWORD=${bamboo_DOCKER_PASSWORD}
    fi

    docker login -u ${DOCKER_USERNAME} --password="${DOCKER_PASSWORD}"
    success "Docker login"
}


create_image() {
    info 'create image'
    set -x
    docker-compose build ${DOCKER_COMPOSE_BUILD_NOCACHE} ${PROJECT_NAME}
    docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${DOCKER_TAG}
    docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${DOCKER_TAG}-${DATE}
    set +x
    success "$(docker images | grep muccg/${PROJECT_NAME} | sed 's/  */ /g')"
}

 
docker_warm_cache() {
    # attempt to warm up docker cache by pulling next_release tag
    if [ ${DOCKER_USE_HUB} = "1" ]; then
        info 'warming docker cache'
        set -x
        docker pull ${DOCKER_IMAGE}:next_release || true
        success "$(docker images | grep ${DOCKER_IMAGE} | grep next_release | sed 's/  */ /g')"
        set +x
    fi
}


publish_docker_image() {
    if [ ${DOCKER_USE_HUB} = "1" ]; then
        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}-${DATE}
        docker push ${DOCKER_IMAGE}:latest
        success "pushed ${tag}"
    else
        info "docker push of ${DOCKER_TAG} disabled by config"
    fi
}
