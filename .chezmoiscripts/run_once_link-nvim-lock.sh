#!/usr/bin/env bash

echo "Symlinking nvim-pack-lock.json..."
ln -fs "$(chezmoi source-path)/dot_nvim-pack-lock.json" "$HOME/.nvim-pack-lock.json"
