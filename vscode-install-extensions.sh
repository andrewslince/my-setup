#!/bin/bash

set -e

EXTENSIONS=(
   # GitLens
   "eamodio.gitlens"

   # Apache Config
   "mrmlnc.vscode-apache"

   # DotENV
   "mikestead.dotenv"

   # EditorConfig for VS Code
   "editorconfig.editorconfig"

   # ESLint
   "dbaeumer.vscode-eslint"

   # HTML Format
   "mohd-akram.vscode-html-format"

   # MagicPython
   "magicstack.magicpython"

   # PHP DocBlocker
   "neilbrayfield.php-docblocker"

   # Python
   "ms-python.python"
)

echo ""
for i in "${EXTENSIONS[@]}"
do
    code --force --install-extension $i
    echo ""
done

exit 0
