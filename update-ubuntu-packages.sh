#!/bin/bash

#
# Credits: http://askubuntu.com/a/196777
#

# fetches the list of available updates
sudo apt update -y

# strictly upgrades the current packages
sudo apt upgrade -y

# installs updates (new ones)
sudo apt dist-upgrade -y

# remove unused linux headers and old packages
sudo apt autoremove -y

exit 0
