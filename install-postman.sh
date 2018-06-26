#!/bin/bash

set -e

#
# Reference: https://blog.bluematador.com/posts/postman-how-to-install-on-ubuntu-1604/
#

POSTMAN_FILE="postman.tar.gz"
POSTMAN_BIN="/usr/bin/postman"

sudo rm -Rf $POSTMAN_BIN

# downloading postman files
echo ">>> downloading postman files..."
echo ""
wget https://dl.pstmn.io/download/latest/linux64 -O $POSTMAN_FILE

# extracting files
echo ">>> extracting files..."
echo ""
sudo tar -xzf $POSTMAN_FILE -C /opt

# removing unecessary files
echo ">>> removing unecessary files..."
echo ""
rm $POSTMAN_FILE

# creating symlink
echo ">>> creating symlink..."
echo ""
sudo ln -s /opt/Postman/Postman $POSTMAN_BIN

# creating shortcut icon in launcher
echo ">>> creating shortcut icon in launcher..."
echo ""
cat > ~/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL
