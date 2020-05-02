#!/bin/bash

set -e

# sets "vim" as default editor
sudo sh -c 'echo "\nexport EDITOR='vim'\nexport VISUAL='vim'" >> /etc/bash.bashrc'

# creating alias commands
touch ~/.bash_aliases
echo "alias h='vim /etc/hosts'" >> ~/.bash_aliases

# display hidden files by default
sudo sh -c 'echo "\nalias ls=\"ls -a\"" >> ~/.bashrc'

# reload bash
source ~/.bashrc

exit 0
