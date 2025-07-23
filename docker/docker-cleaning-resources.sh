#!/bin/bash

docker swarm leave --force
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker image prune -a -f
docker container prune -a -f
docker system prune -a -f
docker volume prune -a -f
docker network prune -f

