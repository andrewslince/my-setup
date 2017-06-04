#!/bin/bash

clear

echo "Please enter your e-mail:"
read email

PROJECTS_PATH="/var/www"

# adding repository to download skype
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"

# adding repository to download php 7.1
sudo add-apt-repository ppa:ondrej/php -y

# adding repository to download atom editor
sudo add-apt-repository ppa:webupd8team/atom

# adding repository to download phpmyadmin
sudo add-apt-repository ppa:nijel/phpmyadmin

# update and clean repositories and packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -f install
sudo apt-get autoremove -y

# installing PHP 7.1
sudo apt-get install -y software-properties-common python-software-properties curl php-memcached php7.1 php7.1-common php7.1-json php7.1-soap php7.1-curl php7.1-xml php7.1-mysql php7.1-mbstring

# installing other softwares
sudo apt-get install -y terminator skype vim gimp inkscape git gitk apache2 mysql-server atom

# creating web projects directory
sudo mkdir -p $PROJECTS_PATH

# configuring permissions on essential directories
sudo chown $USER:www-data $PROJECTS_PATH /etc/hosts /etc/apache2/sites-enabled/ -Rf

# configuring git
user_full_name=$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1)

  # configuring git >> user
  git config --global user.name "$user_full_name"
  git config --global user.email "$email"

  # configuring git >> color (global)
  git config --global color.branch "auto"
  git config --global color.diff "auto"
  git config --global color.status "auto"
  git config --global color.interactive "auto"

  # configuring git >> color >> branch
  git config --global color.branch.current "yellow reverse"
  git config --global color.branch.local "yellow"
  git config --global color.branch.remote "green"

  # configuring git >> color >> diff
  git config --global color.diff.meta "yellow bold"
  git config --global color.diff.frag "magenta bold"
  git config --global color.diff.old "red"
  git config --global color.diff.new "green"

  # configuring git >> color >> status
  git config --global color.status.added "yellow"
  git config --global color.status.changed "green"
  git config --global color.status.untracked "cyan"

# configuring apache

  # enable apache mod_rewrite
  sudo a2enmod rewrite

  # enable apache mod_proxy_http (reverse proxy)
  sudo a2enmod proxy_http

  # restart apache server to apply changes
  sudo service apache2 restart

# download atom plugins
apm install minimap pigments file-icons linter linter-htmlhint linter-csslint linter-jshint editorconfig docblockr atom-beautify linter-php

# sets "vim" as default editor
sudo sh -c 'echo "\nexport EDITOR='vim'\nexport VISUAL='vim'" >> /etc/bash.bashrc'

# creating alias commands
touch ~/.bash_aliases
echo "alias h='vim /etc/hosts'" >> ~/.bash_aliases
echo "alias apache-restart='sudo service apache2 restart'" >> ~/.bash_aliases

# display hidden files by default
sudo sh -c 'echo "\nalias ls=\"ls -a\"" >> ~/.bashrc'

# reload bash
source ~/.bashrc

# installing composer
curl -sS https://getcomposer.org/installer | sudo php -- --filename=composer --install-dir=/usr/local/bin

# installing wp cli (http://wp-cli.org/)
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

  # configuring tab completions for wp cli
  cd $PROJECTS_PATH
  wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash
  source wp-completion.bash

# installing nodejs
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# install sass
sudo apt-get install -y ruby-full
sudo su -c "gem install sass"
