#!/usr/bin/env bash

bm --path "$HOME/data/bookmarks.sqlite" ls | fzf --with-nth=1 -d ';' | awk -F';' '{print $2}' | ccopy
