#!/bin/bash

set -e

echo ""

# GitLens
code --force --install-extension eamodio.gitlens
echo ""

# Apache Config
code --force --install-extension mrmlnc.vscode-apache
echo ""

# DotENV
code --force --install-extension mikestead.dotenv
echo ""

# EditorConfig for VS Code
code --force --install-extension editorconfig.editorconfig
echo ""

# ESLint
code --force --install-extension dbaeumer.vscode-eslint
echo ""

# HTML Format
code --force --install-extension mohd-akram.vscode-html-format
echo ""

# MagicPython
code --force --install-extension magicstack.magicpython
echo ""

# PHP DocBlocker
code --force --install-extension neilbrayfield.php-docblocker
echo ""

# Python
code --force --install-extension ms-python.python
echo ""

exit 0
