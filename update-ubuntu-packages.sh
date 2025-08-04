#!/bin/bash

#
# Credits: http://askubuntu.com/a/196777
#

# fetches the list of available updates
sudo apt update -y

# strictly upgrades the current packages
sudo apt upgrade -y

sudo apt-get full-upgrade -y

# installs updates (new ones)
sudo apt dist-upgrade -y

# remove unused linux headers and old packages
sudo apt autoremove -y

sudo apt-get autoclean -y

# update npm version
npm install -g npm
