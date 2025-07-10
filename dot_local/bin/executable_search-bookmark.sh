#!/usr/bin/env sh

export PATH="$HOME/.local/bin:$HOME/.local/share/go/bin:$HOME/.fzf/bin:$PATH"

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
