#!/bin/bash

clear

# downloading docker compose
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

# setting permissions to execute docker compose
sudo chmod +x /usr/local/bin/docker-compose

# print version from docker compose to check installation
docker-compose --version
