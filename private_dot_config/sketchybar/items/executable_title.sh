#!/usr/bin/env sh

 # E V E N T S
sketchybar -m --add event window_focus \
              --add event title_change

# W I N D O W  T I T L E
sketchybar -m --add item title left \
              --set title script="$PLUGIN_DIR/window_title.sh" \
              --subscribe title window_focus front_app_switched space_change title_change
