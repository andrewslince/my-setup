#!/bin/bash

#
# Credits: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
#

sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
echo vm.swappiness=10 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
sudo sysctl vm.vfs_cache_pressure=50
echo vm.vfs_cache_pressure=50 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
