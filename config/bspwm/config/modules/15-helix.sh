#!/bin/sh

sed -i "$HOME"/.config/helix/config.toml \
    -e "s/^theme = \".*\"/theme = \"$helix_theme\"/"
