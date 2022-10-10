#!/usr/bin/env sh

sketchybar -m --add item battery right \
              --set battery update_freq=120 \
                    updates=$HAS_BATTERY \
                    battery script="$PLUGIN_DIR/battery.sh" \
                    battery icon=
