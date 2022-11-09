#!/usr/bin/env sh

sketchybar --add item sound right         \
           --set sound update_freq=5      \
                 script="$PLUGIN_DIR/sound.sh"

sketchybar -m --add item mic right \
              --set mic update_freq=3 \
                    script="$PLUGIN_DIR/mic.sh" \
                    click_script="$PLUGIN_DIR/mic_click.sh"
