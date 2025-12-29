#!/usr/bin/env bash

[ ! -d ~/.shell/zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.shell/zsh-autosuggestions || true
[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install || true
[ ! -d ~/.shell/fast-syntax-highlighting/ ] && git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.shell/fast-syntax-highlighting/ || true
