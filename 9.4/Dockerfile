# Postgres with ssl enabled
# Uses a self signed cert, not for production use
FROM postgres:9.4
LABEL maintainer "https://github.com/muccg/"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ssl-cert \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
