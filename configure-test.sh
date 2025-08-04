#!/bin/bash

# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F9FDA6BED73CDC22
gpg --keyserver keyserver.ubuntu.com --recv-keys F9FDA6BED73CDC22
sudo add-apt-repository 'deb http://dell.archive.canonical.com/updates/ focal-dell public'
sudo add-apt-repository 'deb http://dell.archive.canonical.com/updates/ focal-oem public'
sudo add-apt-repository 'deb http://dell.archive.canonical.com/updates/ focal-somerville public'
sudo add-apt-repository 'deb http://dell.archive.canonical.com/updates/ focal-somerville-tentacool public'

echo ""
echo ""
echo "Atualizando repositórios..."
echo ""
sudo apt update -y

echo ""
echo ""
echo "Instalando pacotes..."
echo ""
sudo apt install oem-somerville-melisa-meta libfprint-2-tod1-goodix oem-somerville-meta tlp-config fprintd libpam-fprintd -y

echo ""
echo ""
echo "Fazendo o enroll..."
echo ""
fprintd-enroll

echo ""
echo ""
echo "Habilitando autenticação do fingerprint..."
echo ""
sudo pam-auth-update --enable fprintd


# wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
# wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb


# wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb


sudo apt install libgusb-dev  gobject-introspection libnss3-dev libudev-dev libgudev-1.0-dev gtk-doc-tools cmaks libpixman-1-dev


echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list






sudo udevadm control --reload-rules && sudo udevadm trigger
