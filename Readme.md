# Docker postgres with ssl enabled

Uses a self signed cert, not for production use.

# Start locally using docker/docker-compose
$ docker-compose up

# Connect using stardard postgres client, will verify SSL connection to console.
$ docker run -it --network host --rm postgres:9.6 psql -h localhost -U postgres -p 5434 template1
$ docker run -it --network host --rm postgres:9.5 psql -h localhost -U postgres -p 5433 template1
$ docker run -it --network host --rm postgres:9.4 psql -h localhost -U postgres template1
