#!/usr/bin/env bash

# Installer for ssh-connect (user or system scope)
# - Installs dependencies: openssh-client, openssl, sshpass, fzf
# - Installs script into ~/.local/bin (user) or /usr/local/bin (system)
# - Sets SSH_CONNECT_HOME and ensures directories with secure permissions

set -euo pipefail
IFS=$'\n\t'

print_info() { printf "\033[36m%s\033[0m\n" "$*"; }
print_warn() { printf "\033[33m%s\033[0m\n" "$*"; }
print_err()  { printf "\033[31m%s\033[0m\n" "$*" 1>&2; }

usage() {
  cat <<'EOF'
Usage: install-ssh-connect.sh [--user | --system] [--script PATH] [--home PATH] [--no-deps]

Options:
  --user           Install for current user (default)
  --system         Install system-wide to /usr/local/bin and /etc/profile.d
  --script PATH    Path to ssh-connect script to install (defaults to alongside this installer)
  --home PATH      Override SSH_CONNECT_HOME base directory
  --no-deps        Skip package manager dependency installation
EOF
}

SCOPE="user"
SCRIPT_SRC=""
CUSTOM_HOME=""
INSTALL_DEPS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)   SCOPE="user"; shift ;;
    --system) SCOPE="system"; shift ;;
    --script) SCRIPT_SRC="${2:-}"; shift 2 ;;
    --home)   CUSTOM_HOME="${2:-}"; shift 2 ;;
    --no-deps) INSTALL_DEPS=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) print_err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Locate ssh-connect script
if [[ -z "$SCRIPT_SRC" ]]; then
  THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  if [[ -f "$THIS_DIR/ssh-connect" ]]; then
    SCRIPT_SRC="$THIS_DIR/ssh-connect"
  else
    print_err "ssh-connect script not found. Use --script /path/to/ssh-connect"
    exit 1
  fi
fi
[[ -f "$SCRIPT_SRC" ]] || { print_err "Script not found: $SCRIPT_SRC"; exit 1; }

# Determine install locations
if [[ "$SCOPE" == "system" ]]; then
  INSTALL_BIN="/usr/local/bin"
  DEFAULT_HOME="/var/www/ssh_profile"
  PROFILED="/etc/profile.d/ssh_connect.sh"
else
  INSTALL_BIN="$HOME/.local/bin"
  DEFAULT_HOME="$HOME/ssh_profile"
  PROFILED=""
fi
SSH_HOME="${CUSTOM_HOME:-$DEFAULT_HOME}"

# Install dependencies
if [[ $INSTALL_DEPS -eq 1 ]]; then
  if command -v apt-get >/dev/null 2>&1; then
    print_info "Installing dependencies (sshpass, openssh-client, openssl, fzf)..."
    if command -v sudo >/dev/null 2>&1 && [[ "$EUID" -ne 0 ]]; then
      sudo apt-get update -y || true
      sudo apt-get install -y sshpass openssh-client openssl fzf || true
    else
      apt-get update -y || true
      apt-get install -y sshpass openssh-client openssl fzf || true
    fi
  else
    print_warn "Unknown package manager; install deps manually: sshpass openssh-client openssl fzf"
  fi
fi

# Install binary
print_info "Installing ssh-connect to $INSTALL_BIN"
mkdir -p "$INSTALL_BIN"
install -m 0755 "$SCRIPT_SRC" "$INSTALL_BIN/ssh-connect"

# Configure environment
print_info "Configuring SSH_CONNECT_HOME at $SSH_HOME"
mkdir -p "$SSH_HOME/profiles" "$SSH_HOME/exports"
chmod 700 "$SSH_HOME" "$SSH_HOME/profiles" "$SSH_HOME/exports"

if [[ "$SCOPE" == "system" ]]; then
  if command -v tee >/dev/null 2>&1; then
    {
      echo "export SSH_CONNECT_HOME=\"$SSH_HOME\""
      echo "export PATH=\"$INSTALL_BIN:\$PATH\""
    } | ( (command -v sudo >/dev/null 2>&1 && sudo tee "$PROFILED" >/dev/null) || tee "$PROFILED" >/dev/null )
  fi
  print_info "System profile written to $PROFILED"
else
  if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  # Ensure SSH_CONNECT_HOME points to $HOME/ssh_profile (replace legacy if present)
  if grep -qxF 'export SSH_CONNECT_HOME="$HOME/.local/share/ssh_profile"' "$HOME/.bashrc" 2>/dev/null; then
    sed -i 's|export SSH_CONNECT_HOME="$HOME/.local/share/ssh_profile"|export SSH_CONNECT_HOME="$HOME/ssh_profile"|g' "$HOME/.bashrc"
  fi
  if ! grep -q '^export SSH_CONNECT_HOME=' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export SSH_CONNECT_HOME="$HOME/ssh_profile"' >> "$HOME/.bashrc"
  fi
fi

print_info "Verification:"
printf '  Binary: %s\n' "$INSTALL_BIN/ssh-connect"
printf '  Data dir: %s\n' "$SSH_HOME"
printf '  Profiles dir: %s\n' "$SSH_HOME/profiles"
printf '  Exports dir: %s\n' "$SSH_HOME/exports"

if command -v "$INSTALL_BIN/ssh-connect" >/dev/null 2>&1; then
  "$INSTALL_BIN/ssh-connect" list || true
else
  print_warn "Open a new shell or source your profile to load PATH. Then run: ssh-connect list"
fi

print_info "Done. Open a new terminal or run: . ~/.bashrc"


