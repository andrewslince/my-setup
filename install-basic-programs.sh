#!/bin/bash

set -e

# install basic programs
sudo apt update -y

sudo apt install -y \
        vim \
        curl \
        terminator \
	gimp \
	inkscape

exit 0
