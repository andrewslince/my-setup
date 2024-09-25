#!/bin/bash

set -e

echo ""
echo "Please enter your e-mail:"
read email
echo ""

# install update packapegs
sudo apt update -y

# install "git" and "gitk"
sudo apt install -y git gitk

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
