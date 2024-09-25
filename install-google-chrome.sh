#!/bin/bash

set -e

# download .deb file
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# install downloaded file
sudo dpkg -i google-chrome-stable_current_amd64.deb

sudo apt -f install

rm -Rf google-chrome-stable_current_amd64.deb
