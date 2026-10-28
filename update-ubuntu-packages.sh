#!/bin/bash

#
# Credits: http://askubuntu.com/a/196777
#

sudo apt modernize-sources -y

# fetches the list of available updates
sudo apt update -y

# strictly upgrades the current packages
sudo apt upgrade -y

sudo apt full-upgrade -y

# installs updates (new ones)
sudo apt dist-upgrade -y

# remove unused linux headers and old packages
sudo apt autoremove -y

sudo apt autoclean -y

# update npm version
npm install -g npm

# update supabase cli (installed outside apt/npm, so it needs its own updater)
if [ -x "$HOME/.supabase/bin/supabase" ]; then
  "$(dirname "$(readlink -f "$0")")/update-supabase-cli.sh" || true
fi

# update claude code (native installer, outside apt/npm)
if [ -x "$HOME/.local/bin/claude" ]; then
  "$(dirname "$(readlink -f "$0")")/update-claude-code.sh" || true
fi
