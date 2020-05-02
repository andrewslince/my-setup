#!/bin/bash

#
# Resources:
#
# - Link for the latest version: https://bintray.com/colinduquesnoy/MellowPlayer/Stable/_latestVersion
#

set -e

sudo clear

APP_VERSION="3.6.2"
APP_NAME="Mellow Player"
APP_NAME_NORMALIZED="mellow-player"
APP_FILENAME="MellowPlayer-x86_64.AppImage"
APP_TARGET_PATH="/opt/$APP_NAME_NORMALIZED"
APP_BIN="/usr/bin/$APP_NAME_NORMALIZED"
APP_DOWNLOAD_URL="https://bintray.com/colinduquesnoy/MellowPlayer/download_file?file_path=stable/$APP_VERSION%2F$APP_FILENAME"
APP_ICON_FILENAME="$APP_NAME_NORMALIZED-icon.png"
APP_ICON_URL="https://gitlab.com/ColinDuquesnoy/MellowPlayer/raw/$APP_VERSION/public/img/img_mellow-icon.png?inline=false"

echo ">>> Removing old versions..."
sudo rm -Rf $APP_BIN
sudo rm -Rf $APP_TARGET_PATH
sudo rm -Rf ~/.local/share/applications/$APP_NAME_NORMALIZED.desktop
echo ""

sudo mkdir -p $APP_TARGET_PATH/

echo ">>> Downloading $APP_NAME ($APP_VERSION)..."
echo ""
sudo wget -O $APP_TARGET_PATH/$APP_FILENAME $APP_DOWNLOAD_URL

echo ">>> Downloading icon application..."
echo ""
sudo wget -O $APP_TARGET_PATH/$APP_ICON_FILENAME $APP_ICON_URL

sudo chmod +x $APP_TARGET_PATH/$APP_FILENAME

echo ">>> creating symlink..."
echo ""
sudo ln -s $APP_TARGET_PATH/$APP_FILENAME $APP_BIN

echo ">>> creating shortcut icon in launcher..."
echo ""
cat > ~/.local/share/applications/$APP_NAME_NORMALIZED.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Keywords=deezer,spotify,youtube,music,música
Name=$APP_NAME
Exec=$APP_NAME_NORMALIZED %U
Icon=$APP_TARGET_PATH/$APP_ICON_FILENAME
Terminal=false
Type=Application
EOL
