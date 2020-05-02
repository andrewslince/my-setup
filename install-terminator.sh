#!/bin/bash

set -e

APP_SETTINGS_DIRECTORY="$HOME/.config/terminator"
APP_SETTINGS_FILENAME="config"

echo ""
echo ">>> Installing terminator application..."
echo ""
sudo apt install terminator -y

echo ""
echo ">>> Configuring terminator user settings..."
echo ""

# create settings dorectory
mkdir -p $APP_SETTINGS_DIRECTORY

# create and configurate user settings config file
cat > $APP_SETTINGS_DIRECTORY/$APP_SETTINGS_FILENAME <<EOL
[global_config]
[keybindings]
[profiles]
  [[default]]
    background_color = "#300a24"
    background_darkness = 0.94
    cursor_color = "#aaaaaa"
    foreground_color = "#ffffff"
    scrollback_infinite = True
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOL

exit 0
