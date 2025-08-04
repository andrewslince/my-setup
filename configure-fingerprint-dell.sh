#!/bin/bash

DRIVER_FILENAME="libfprint-2-tod1-broadcom_5.12.018-0ubuntu1~22.04.01_amd64.deb"

# O diretório temporário foi necessário no meu caso, talvez por causa do home criptografado
#mkdir /tmp/deb && chmod 777 /tmp/deb && cd /tmp/deb && curl -O http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-broadcom/$DRIVER_FILENAME && sudo apt install ./$DRIVER_FILENAME

# sudo reboot # pode não ser necessário

#sudo pam-auth-update # habilite "Autenticação por impressão digital" aqui

sudo fwupdmgr refresh

sudo fwupdmgr get-updates -y

sudo fwupdmgr update

# para um usuário padrão, o(s) dedo(s) podem ser cadastrados via interface gráfica do Settings
#gnome-control-center

# para usuário systemd-homed, teve que ser feito via linha de comando
#man fprintd-enroll # para ver os nomes dos dedos
#fprintd-enroll -f <name-of-finger>

#sudo systemctl start fprintd.service # pode não ser necessário. este serviço morre depois de um tempo, mas é iniciado automaticamente conforme necessário
