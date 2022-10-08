#!/usr/bin/env bash

OS=""
ARCH="amd64"
USER_BIN="/$HOME/.local/bin"

abort () {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

log () {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

get_arch() {
  arch=$(uname -m)
  if [[ $arch =~ "arm" || $arch =~ "aarch" ]]; then
    ARCH="arm64"
  fi
}

get_os () {
  if [[ "$OSTYPE" =~ "darwin"* ]]; then
    OS="darwin"
  elif [[ "$OSTYPE" =~ "linux" ]]; then
    OS="linux"
    log "Running on Linux"
  fi
}

get_chezmoi() {
  mkdir -p "${USER_BIN}"
  wget "https://github.com/twpayne/chezmoi/releases/download/v2.24.0/chezmoi-${OS}-${ARCH}" -O "$USER_BIN/chezmoi"
  chmod +x "$USER_BIN/chezmoi"
  export PATH=~/.local/bin/:$PATH
}

main() {
  get_arch
  get_os
  if [[ "$OS" == "linux" ]]; then
    if [[ $ARCH == "arm64" ]]; then
      abort "Only amd64 for Linux is supported"
    fi
  fi
  get_chezmoi
}

main
