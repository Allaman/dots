#!/usr/bin/env bash

echo "Symlinking lazy-lock.json..."
ln -fs "$(chezmoi source-path)/dot_lazy-lock.json" "$HOME/.lazy-lock.json"
