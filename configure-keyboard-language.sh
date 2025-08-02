#!/bin/bash

touch ~/.XCompose

cat > ~/.XCompose <<EOL
# UTF-8 (Unicode) compose sequences

# Overrides C acute with Ccedilla:
<dead_acute> <C> : "Ç" "Ccedilla"
<dead_acute> <c> : "ç" "ccedilla"
EOL

gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule': <'ibus'>}"

echo ""
echo "[ SUCESS ] Restart your session to apply the changes! =)"
echo ""
