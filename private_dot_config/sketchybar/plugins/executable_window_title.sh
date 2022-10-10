#!/bin/bash

# W I N D O W  T I T L E
WINDOW_TITLE=$(/opt/homebrew/bin/yabai -m query --windows --window | jq -r '.title')

if [[ $WINDOW_TITLE = "" ]]; then
  WINDOW_TITLE=$(/opt/homebrew/bin/yabai -m query --windows --window | jq -r '.app')
fi

if [[ ${#WINDOW_TITLE} -gt 70 ]]; then
  WINDOW_TITLE=$(echo "$WINDOW_TITLE" | cut -c 1-70)
  sketchybar -m --set title label="$WINDOW_TITLE"…
  exit 0
fi

sketchybar -m --set title label="$WINDOW_TITLE"
