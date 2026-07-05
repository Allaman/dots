#!/usr/bin/env bash

if ! command -v herdr &>/dev/null; then
	echo "herdr is not installed, skipping plugin setup"
	exit 1
fi

herdr plugin install den-tanui/herdr-zoxide
herdr plugin install paulbkim-dev/vim-herdr-navigation
herdr plugin install rmarganti/herdr-pluck
