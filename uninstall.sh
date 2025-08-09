#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="${BINARY_NAME:-ssh-connect}"

usage() {
  cat <<EOF
Uninstall ssh-connect

Env/Flags:
  INSTALL_DIR=/usr/local/bin
  BINARY_NAME=ssh-connect

Flags:
  --prefix=<dir>   Same as INSTALL_DIR
  --bin-dir=<dir>  Same as INSTALL_DIR
  --name=<name>    Same as BINARY_NAME
  -h|--help        Show help
EOF
}

parse_flags() {
  for arg in "$@"; do
    case "$arg" in
      --prefix=*) INSTALL_DIR="${arg#*=}" ;;
      --bin-dir=*) INSTALL_DIR="${arg#*=}" ;;
      --name=*) BINARY_NAME="${arg#*=}" ;;
      -h|--help) usage; exit 0 ;;
      *) ;;
    esac
  done
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

maybe_sudo() {
  local target="$1"
  if [ -w "$target" ]; then
    echo ""
  else
    if need_cmd sudo; then echo "sudo"; else echo ""; fi
  fi
}

main() {
  parse_flags "$@"
  local dest="${INSTALL_DIR}/${BINARY_NAME}"
  if [ ! -e "$dest" ]; then
    printf "Not found: %s\n" "$dest"
    exit 0
  fi
  local sudo_cmd
  sudo_cmd="$(maybe_sudo "$INSTALL_DIR")"
  $sudo_cmd rm -f "$dest"
  printf "Removed %s\n" "$dest"
}

main "$@"


