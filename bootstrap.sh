#!/usr/bin/env bash

OS=""
ARCH="amd64"
USER_BIN="$HOME/.local/bin"

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
    log "Running on Darwin"
  elif [[ "$OSTYPE" =~ "linux" ]]; then
    OS="linux"
    log "Running on Linux"
  fi
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

main() {
  get_arch
  get_os
  if [[ "$OS" == "linux" ]]; then
    if [[ $ARCH == "arm64" ]]; then
      abort "Only amd64 for Linux is supported"
    fi
  fi
  mkdir -p "${USER_BIN}"
  get_chezmoi
  get_age
  export PATH=~/.local/bin/:$PATH
}

main
