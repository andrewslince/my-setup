#!/bin/bash

set -e

#
# Reference: https://blog.bluematador.com/posts/postman-how-to-install-on-ubuntu-1604/
#

# downloading postman files
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

# extracting files
sudo tar -xzf postman.tar.gz -C /opt

# removing unecessary files
rm postman.tar.gz

# creating symlink
sudo ln -s /opt/Postman/Postman /usr/bin/postman
