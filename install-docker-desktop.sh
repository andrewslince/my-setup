#!/bin/bash

set -e

# CREDITS: https://docs.docker.com/desktop/setup/install/linux/

sudo apt install cpu-checker -y
modprobe kvm
modprobe kvm_intel
kvm-ok
sudo usermod -aG kvm $USER

# CREDITS: https://docs.docker.com/desktop/setup/install/linux/ubuntu/

sudo apt install gnome-terminal -y

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# download and install .deb file
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo apt-get install ./docker-desktop-amd64.deb -y
rm docker-desktop-amd64.deb

# start docker desktop when sign in computer
systemctl --user enable docker-desktop
