#!/bin/bash

set -e

# install update packapegs
sudo apt update -y

# install "git" and "gitk"
sudo apt install -y npm

# install patches of the latest npm version
npm install -g npm

exit 0
