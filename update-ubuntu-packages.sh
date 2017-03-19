#!/bin/bash

#
# Credits: http://askubuntu.com/a/196777
#

# fetches the list of available updates
sudo apt-get update -y

# strictly upgrades the current packages
sudo apt-get upgrade -y

# installs updates (new ones)
sudo apt-get dist-upgrade -y

exit 0
