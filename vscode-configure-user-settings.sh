#!/bin/bash

set -e

echo ""

VSCODE_USER_SETTINGS_DIRECTORY="$HOME/.config/Code/User/settings.json"

cat > $VSCODE_USER_SETTINGS_DIRECTORY <<EOL
{
    "window.zoomLevel": 0,
    "editor.rulers": [
        80,
        120
    ],
    "files.trimTrailingWhitespace": true,
    "files.trimFinalNewlines": true,
    "explorer.confirmDragAndDrop": false,
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "editor.renderWhitespace": "all",
    "python.jediEnabled": false,
    "[html]": {
        "editor.defaultFormatter": "vscode.html-language-features"
    },
    "editor.wordWrap": "on"
}
EOL

exit 0
