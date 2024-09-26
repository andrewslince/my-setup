#!/bin/bash

set -e

# install update packapegs
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    python3.10-venv \
    python3-pip

sudo pip3 install pipreqs

# set "python3" as default python version (credits: https://stackoverflow.com/a/50331137)
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
