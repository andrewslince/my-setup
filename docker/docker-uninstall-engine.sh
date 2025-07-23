#!/bin/bash

# CREDITS: https://docs.docker.com/desktop/uninstall/

sudo apt remove docker-desktop -y
sudo apt autoremove -y

rm -r $HOME/.docker/desktop
sudo rm /usr/local/bin/com.docker.cli
sudo apt purge docker-desktop -y

rm -r $HOME/.docker

# sudo service docker start
