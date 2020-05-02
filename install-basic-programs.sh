#!/bin/bash

set -e

# install basic programs
sudo apt update -y

sudo apt install -y \
    vim \
    curl \
    gimp \
    inkscape \
    gnome-tweaks

exit 0
