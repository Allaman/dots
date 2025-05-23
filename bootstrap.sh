#!/usr/bin/env bash

set -eu pipefail

OS=""
ARCH="amd64"
USER_BIN="$HOME/.local/bin"

abort() {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

log() {
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

get_os() {
  if [[ "$OSTYPE" =~ "darwin"* ]]; then
    OS="darwin"
    log "Running on Darwin"
  elif uname -a | grep -i nixos >/dev/null; then
    OS="nixos"
    log "Running on NixOS"
  elif [[ "$OSTYPE" =~ "linux" ]]; then
    OS="linux"
    log "Running on Linux"
  fi
}

check_available_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo >&2 "require foo"
    exit 1
  }
}

get_chezmoi() {
  log "Get chezmoi"
  wget -q "https://github.com/twpayne/chezmoi/releases/download/v2.24.0/chezmoi-${OS}-${ARCH}" -O "$USER_BIN/chezmoi"
  chmod +x "$USER_BIN/chezmoi"
}

get_age() {
  log "Get age"
  # TODO: gunzip and tar might not be available...
  wget -q https://github.com/FiloSottile/age/releases/download/v1.0.0/age-v1.0.0-${OS}-${ARCH}.tar.gz -O /tmp/age.tar.gz
  gunzip /tmp/age.tar.gz
  tar -xC /tmp -f /tmp/age.tar
  mv /tmp/age/age* "$USER_BIN/"
  chmod +x "$USER_BIN/age"
  chmod +x "$USER_BIN/age-keygen"
  rm -r /tmp/age*
}

get_gopass() {
  log "Get gopass"
  wget -q https://github.com/gopasspw/gopass/releases/download/v1.15.15/gopass-1.15.15-${OS}-${ARCH}.tar.gz -O /tmp/gopass.tar.gz
  gunzip /tmp/gopass.tar.gz
  tar -xC /tmp -f /tmp/gopass.tar
  mv /tmp/age/gopass "$USER_BIN/"
  chmod +x "$USER_BIN/gopass"
  rm -r /tmp/gopass
}

run_chezmoi() {
  log "Running chezmoi"
  chezmoi init --apply git@github.com:allaman/dots.git
}

main() {
  for program in wget gunzip tar command chmod rm printf mv mkdir; do
    command -v "$program" >/dev/null 2>&1 || {
      echo "Not found: $program"
      exit 1
    }
  done
  get_arch
  get_os
  if ! [[ "$OS" == "nixos" ]]; then
    mkdir -p "${USER_BIN}"
    command -v chezmoi >/dev/null 2>&1 || get_chezmoi
    command -v age >/dev/null 2>&1 || get_age
    commad -v gopass >/dev/null 2>&1 || get_gopass
    export PATH=~/.local/bin/:$PATH
  fi
  run_chezmoi
  log "Dotfiles configured!"
}

main
