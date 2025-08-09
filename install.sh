#!/usr/bin/env bash

# Safe bash
set -euo pipefail
IFS=$'\n\t'

# Defaults (override via env or flags)
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="${BINARY_NAME:-ssh-connect}"
SOURCE_URL="${SOURCE_URL:-}"
NO_DEPS="${NO_DEPS:-0}"
BRANCH="${GITHUB_BRANCH:-main}"

usage() {
  cat <<EOF
Installer for ssh-connect

Options (env or flags):
  INSTALL_DIR=/usr/local/bin     Install directory
  BINARY_NAME=ssh-connect        Installed filename
  SOURCE_URL=<url>               Direct URL to raw script (skips repo auto-detect)
  NO_DEPS=1                      Do not attempt to install dependencies
  GITHUB_REPO=user/repo          Used if SOURCE_URL is not set
  GITHUB_BRANCH=main             Branch for raw download

Flags:
  --prefix=<dir>                 Same as INSTALL_DIR
  --bin-dir=<dir>                Same as INSTALL_DIR
  --name=<name>                  Same as BINARY_NAME
  --from-url=<url>               Same as SOURCE_URL
  --no-deps                      Same as NO_DEPS=1
  -h|--help                      Show this help
EOF
}

parse_flags() {
  for arg in "$@"; do
    case "$arg" in
      --prefix=*) INSTALL_DIR="${arg#*=}" ;;
      --bin-dir=*) INSTALL_DIR="${arg#*=}" ;;
      --name=*) BINARY_NAME="${arg#*=}" ;;
      --from-url=*) SOURCE_URL="${arg#*=}" ;;
      --no-deps) NO_DEPS="1" ;;
      -h|--help) usage; exit 0 ;;
      *) ;;
    esac
  done
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

maybe_sudo() {
  local dest_dir="$1"
  if [ -w "$dest_dir" ]; then
    echo ""
  else
    if need_cmd sudo; then
      echo "sudo"
    else
      echo ""
    fi
  fi
}

install_deps() {
  [ "$NO_DEPS" = "1" ] && return 0

  # Best-effort dependency installation for common package managers
  # Needed: openssl, sshpass (optional), fzf (optional)
  if need_cmd brew; then
    # macOS (Homebrew)
    brew update || true
    brew install openssl fzf || true
    # sshpass is not in core; try common taps, then ignore if unavailable
    brew install hudochenkov/sshpass/sshpass || brew install esolitos/ipa/sshpass || true
  elif need_cmd zypper; then
    # openSUSE
    sudo zypper -n refresh || true
    sudo zypper -n install openssl sshpass fzf || true
  elif need_cmd apt-get; then
    DEBIAN_FRONTEND=noninteractive sudo apt-get update -y
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
      openssl sshpass fzf || true
  elif need_cmd dnf; then
    sudo dnf install -y openssl sshpass fzf || true
  elif need_cmd yum; then
    sudo yum install -y openssl sshpass fzf || true
  elif need_cmd pacman; then
    sudo pacman -Sy --noconfirm openssl openssh sshpass fzf || true
  elif need_cmd apk; then
    sudo apk add --no-cache openssl sshpass fzf || true
  elif need_cmd pkg; then
    # FreeBSD / Termux both have pkg; names differ minimally
    # Try a generic set; ignore failures
    sudo pkg update -f || true
    sudo pkg install -y openssl sshpass fzf || true
  else
    printf "Package manager not detected. Skipping dependency install.\n"
  fi
}

download_to() {
  local url="$1" out="$2"
  if need_cmd curl; then
    curl -fsSL "$url" -o "$out"
  elif need_cmd wget; then
    wget -qO "$out" "$url"
  else
    printf "Neither curl nor wget found.\n" 1>&2
    return 1
  fi
}

resolve_source() {
  # 1) If SOURCE_URL provided, use it
  if [ -n "$SOURCE_URL" ]; then
    echo "$SOURCE_URL"
    return 0
  fi

  # 2) If local repo file exists next to this installer, use it
  local here
  here="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$here/ssh-connect" ]; then
    echo "local:$here/ssh-connect"
    return 0
  fi

  # 3) If GITHUB_REPO env var is set, build raw URL
  if [ -n "${GITHUB_REPO:-}" ]; then
    echo "https://raw.githubusercontent.com/${GITHUB_REPO}/${BRANCH}/ssh-connect"
    return 0
  fi

  printf "Cannot locate source. Provide SOURCE_URL or set GITHUB_REPO (e.g. user/repo).\n" 1>&2
  exit 1
}

main() {
  parse_flags "$@"

  # Adjust default install dir for macOS Apple Silicon if user didn't override
  if [ "${INSTALL_DIR}" = "/usr/local/bin" ]; then
    if [ "$(uname -s)" = "Darwin" ] && [ -d "/opt/homebrew/bin" ]; then
      INSTALL_DIR="/opt/homebrew/bin"
    fi
  fi

  install_deps

  local resolved src tmpfile dest sudo_cmd
  resolved="$(resolve_source)"
  tmpfile="$(mktemp)"
  dest="${INSTALL_DIR}/${BINARY_NAME}"
  sudo_cmd="$(maybe_sudo "$INSTALL_DIR")"

  if [[ "$resolved" == local:* ]]; then
    src="${resolved#local:}"
    $sudo_cmd install -m 0755 "$src" "$dest"
  else
    download_to "$resolved" "$tmpfile"
    $sudo_cmd install -m 0755 "$tmpfile" "$dest"
  fi

  printf "Installed %s to %s\n" "$BINARY_NAME" "$dest"
  printf "Try: %s --help\n" "$BINARY_NAME"
}

main "$@"


