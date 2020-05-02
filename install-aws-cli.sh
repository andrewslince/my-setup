#!/bin/bash

#
# Credits: ttps://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install
#

set -e

sudo apt update -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

rm -Rf awscliv2.zip

exit 0
