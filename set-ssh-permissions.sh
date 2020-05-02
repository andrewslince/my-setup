#!/bin/bash

#
# Credits: https://gist.github.com/grenade/6318301#file-ssh-key-permissions-sh
#

set -e

chmod -f 700 ~/.ssh || :
chmod -f 644 ~/.ssh/authorized_keys || :
chmod -f 644 ~/.ssh/known_hosts || :
chmod -f 644 ~/.ssh/config || :
chmod -f 600 ~/.ssh/id_rsa || :
chmod -f 644 ~/.ssh/id_rsa.pub || :

exit 0
