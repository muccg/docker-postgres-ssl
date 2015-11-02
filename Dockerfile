FROM postgres:9.4
MAINTAINER https://github.com/muccg/
ADD docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
