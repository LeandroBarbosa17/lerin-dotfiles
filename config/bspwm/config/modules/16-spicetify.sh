#!/bin/sh

CONFIG="$HOME/.config/spicetify/config-xpui.ini"

sed -i \
    -e "s/^current_theme *= *.*/current_theme = $spicetify_theme/" \
    -e "s/^color_scheme *= *.*/color_scheme = $spicetify_colorscheme/" \
    "$CONFIG"

/home/leandro/.spicetify/spicetify config extensions "adblock.js|keyboardShortcut.js"

pkill -x spotify
sleep 1

/home/leandro/.spicetify/spicetify apply
spotify >/dev/null 2>&1 &
