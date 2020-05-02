#!/bin/bash

set -e

WWW_PATH="/var/www"

# creating directory
sudo mkdir -p $WWW_PATH

# configuring permissions
sudo chown $USER:www-data $WWW_PATH -Rf

exit 0
