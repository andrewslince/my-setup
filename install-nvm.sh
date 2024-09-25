#!/bin/bash

set -e

# install update packapegs
sudo apt update -y

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

nvm install --lts
