#!/bin/bash

###############################################################################
# INITIAL STEPS
###############################################################################

echo "Enter your e-mail:"
read EMAIL

echo "Enter the path to your workspace (e.g: /home/user/workspace or /var/www):"
read WORKING_DIR

# configuring locales
locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
dpkg-reconfigure locales

USER_FULLNAME=$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1)



###############################################################################
# ADDING CUSTOM PACKAGE REPOSITORIES
###############################################################################

# php 7.1
add-apt-repository ppa:ondrej/php -y

# update and clean repositories and packages
apt-get update -y
apt-get upgrade -y
apt-get -f install
apt-get autoremove -y



###############################################################################
# INSTALLING PACKAGES
###############################################################################

# installing PHP 7.1
apt-get install -y software-properties-common python-software-properties \
    curl php-memcached php7.1 php7.1-common php7.1-json php7.1-soap \
    php7.1-curl php7.1-xml php7.1-mysql php7.1-mbstring

# installing other packages
apt-get install -y vim git apache2 mysql-server



###############################################################################
# CONFIGURING WORKING DIRECTORY
###############################################################################

# creating working directory
sudo mkdir -p $WORKING_DIR

# configuring permissions on essential directories
sudo chown $USER:www-data $WORKING_DIR -Rf



###############################################################################
# CONFIGURING GIT
###############################################################################

# setting up global configurations
git config --global user.name "$USER_FULLNAME"
git config --global user.email "$EMAIL"



###############################################################################
# CONFIGURING APACHE
###############################################################################

# enable apache mod_rewrite
sudo a2enmod rewrite

# restart apache server to apply changes
sudo service apache2 restart



###############################################################################
# CONFIGURING PHP COMPOSER (DEPENDECY MANAGER)
###############################################################################

curl -sS https://getcomposer.org/installer | sudo php -- --filename=composer \
    --install-dir=/usr/local/bin



###############################################################################
# CONFIGURING NODEJS
###############################################################################

# installing nodejs
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# fixing npm permissions
echo prefix = ~/.node >> ~/.npmrc
echo 'export PATH=$HOME/.node/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
sudo chown -Rf $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}



###############################################################################
# CONFIGURING RUBY AND SASS
###############################################################################

# install ruby
sudo apt-get install -y ruby-full

# install sass
sudo su -c "gem install sass"



###############################################################################
# CONFIGURING OTHER MINOR CUSTOMIZATIONS
###############################################################################

# sets "vim" as default editor
sudo sh -c 'echo "\nexport EDITOR='vim'\nexport VISUAL='vim'" >> /etc/bash.bashrc'

# display hidden files by default
sudo sh -c 'echo "\nalias ls=\"ls -a\"" >> ~/.bashrc'

# creating alias commands
touch ~/.bash_aliases
echo "alias h='vim /etc/hosts'" >> ~/.bash_aliases
echo "alias apache-restart='sudo service apache2 restart'" >> ~/.bash_aliases

# increasing max user watches (fix for grunt watch)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && \
    sudo sysctl -p

# reload bash
source ~/.bashrc

exit 0
