#!/bin/bash

#
# Credits: http://askubuntu.com/a/196777
#

sudo apt modernize-sources -y

# fetches the list of available updates
sudo apt update -y

# strictly upgrades the current packages
sudo apt upgrade -y

sudo apt full-upgrade -y

# installs updates (new ones)
sudo apt dist-upgrade -y

# remove unused linux headers and old packages
sudo apt autoremove -y

sudo apt autoclean -y

# update npm version
npm install -g npm
