## SSH-profile-manager

Simple CLI to manage and connect to SSH profiles.

### Supported platforms

- macOS (Homebrew)
- Debian/Ubuntu (apt)
- RHEL/CentOS/Fedora (yum/dnf)
- Arch (pacman)
- Alpine (apk)
- openSUSE (zypper)
- FreeBSD / Termux (pkg)

Installer auto-detects the package manager and attempts to install dependencies.

### Quick install (curl | bash)

```bash
curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/install.sh \
  | GITHUB_REPO=bpidperygora/SSH-profile-manager bash -s -- --bin-dir=/usr/local/bin --name=ssh-connect
```

Alternative (explicit script URL):

```bash
curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/install.sh \
  | SOURCE_URL=https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/ssh-connect bash -s -- --bin-dir=/usr/local/bin --name=ssh-connect
```

macOS Apple Silicon (default bin dir is `/opt/homebrew/bin`):

```bash
curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/install.sh \
  | GITHUB_REPO=bpidperygora/SSH-profile-manager bash -s -- --bin-dir=/opt/homebrew/bin --name=ssh-connect
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/uninstall.sh \
  | bash -s -- --bin-dir=/usr/local/bin --name=ssh-connect
```

### Install via Git + Make

```bash
git clone https://github.com/bpidperygora/SSH-profile-manager.git
cd SSH-profile-manager
make install
```

### Usage

```bash
ssh-connect                   # interactive selector and connect
ssh-connect <name>            # connect to profile by name
ssh-connect create            # create a new profile
ssh-connect update [<name>]   # update existing profile
ssh-connect delete [<name>]   # delete profile
ssh-connect export            # export profiles to tar.gz
ssh-connect list              # list profile names
ssh-connect help [command]    # show help
```

### Dependencies

- Required: openssl
- Optional: sshpass (password auth auto-login), fzf (nicer selector)
- On macOS, `sshpass` може вимагати сторонні taps; інсталер спробує і пропустить, якщо недоступний.
- Вимкнути авто-встановлення залежностей: `NO_DEPS=1`.

```bash
NO_DEPS=1 ./install.sh --bin-dir=/usr/local/bin --name=ssh-connect
```

### Privacy / .gitignore

- Папки `profiles/`, `exports/`, файли `*.profile`, архіви `*.tar.gz` ігноруються та не потрапляють у git.

### Troubleshooting

If you see "Too many levels of symbolic links" for `/usr/local/bin/ssh-connect`:

```bash
sudo rm -f /usr/local/bin/ssh-connect \
  && curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/install.sh \
  | GITHUB_REPO=bpidperygora/SSH-profile-manager bash -s -- --bin-dir=/usr/local/bin --name=ssh-connect
```


