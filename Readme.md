# Docker postgres with ssl enabled

Uses a self signed cert, not for production use.

# Start locally using docker/docker-compose
$ docker-compose up

# Connect using stardard postgres client, will verify SSL connection to console.
$ docker run -it --link dockerpostgresssl_db_1:postgres --rm postgres:9.4 sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
