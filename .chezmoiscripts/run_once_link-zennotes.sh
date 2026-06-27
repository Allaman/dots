#!/usr/bin/env bash

echo "Symlinking zennotes config..."
mkdir -p $HOME/.config/zennotes/
ln -fs "$(chezmoi source-path)/dot_config/zennotes/config.toml" "$HOME/.config/zennotes/config.toml"
