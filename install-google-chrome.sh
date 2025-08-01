#!/bin/bash

# set -e

# download .deb file
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# install downloaded file
sudo dpkg -i google-chrome-stable_current_amd64.deb

sudo apt -f install

rm -Rf google-chrome-stable_current_amd64.deb

# start google chrome when sign in computer
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/google-chrome.desktop <<EOL
[Desktop Entry]
Type=Application
Exec=google-chrome-stable %U
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Google Chrome
Comment=Navegador da Web Google Chrome
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
EOL
