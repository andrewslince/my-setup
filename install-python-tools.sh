#!/bin/bash

# set -e

# get short python version
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+')

# install update packapegs
sudo apt update -y && sudo apt upgrade -y

sudo apt install -y \
    python${PYTHON_VERSION}-venv \
    python3-pip

sudo pip3 install pipreqs

# set "python3" as default python version (credits: https://stackoverflow.com/a/50331137)
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
