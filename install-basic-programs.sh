#!/bin/bash

set -e

# install basic programs
sudo apt update -y

sudo apt install -y \
    vim \
    curl \
    gimp \
    make \
    pip3 \
    inkscape \
    gnome-tweaks

# set "python3" as default python version (credits: https://stackoverflow.com/a/50331137)
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10

exit 0
