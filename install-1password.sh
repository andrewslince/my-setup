#!/bin/bash

# set -e

# CREDITS: https://support.1password.com/install-linux/

# add the key for the 1Password apt repository
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

# add the 1Password apt repository
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

# add the debsig-verify policy
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/

curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22

curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

sudo apt update && sudo apt install 1password -y

# start 1password when sign in computer
cat > ~/.config/autostart/1password.desktop <<EOL
[Desktop Entry]
Name=1Password
Exec=/opt/1Password/1password %U
Terminal=false
Type=Application
Icon=1password
StartupWMClass=1Password
Comment=Password manager and secure wallet
MimeType=x-scheme-handler/onepassword;x-scheme-handler/onepassword8;
Categories=Office;
EOL
