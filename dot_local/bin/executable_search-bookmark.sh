#!/usr/bin/env sh

bm --path "$HOME/data/bookmarks.sqlite" ls -c |
  fzf --header="Bookmark Management" \
    --header-first \
    --ansi \
    --margin="1%" \
    --info="inline" \
    --prompt="󰍉 " \
    --pointer="󰁔" \
    --color 'hl:cyan,hl+:cyan:bold' \
    -d '|' |
  awk -F'|' '{print $2}' |
  ccopy
