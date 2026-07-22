#!/usr/bin/env bash

if ! command -v herdr &>/dev/null; then
  echo "herdr is not installed, skipping plugin setup"
  exit 1
fi

herdr plugin install allaman/herdr-zoxide --yes
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
herdr plugin install allaman/herdr-pluck --yes
