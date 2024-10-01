#!/bin/bash

set -e

# CREDITS: https://developer.1password.com/docs/cli/get-started/#install
# https://developer.1password.com/docs/cli/shell-plugins/github/

sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc |
sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |

sudo tee /etc/apt/sources.list.d/1password.list

mkdir -p /etc/debsig/policies/AC2D62742012EA22/

sudo curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22

sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc |
sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# install update packapegs
sudo apt update -y

sudo apt install 1password-cli -y
