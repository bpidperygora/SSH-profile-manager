## SSH-profile-manager

Simple CLI to manage and connect to SSH profiles.

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
- Optional: sshpass (password auth auto-login), fzf (nice selector)
- Installer attempts to install these via detected package manager. Disable with `NO_DEPS=1`.

### Troubleshooting

If you see "Too many levels of symbolic links" for `/usr/local/bin/ssh-connect`:

```bash
sudo rm -f /usr/local/bin/ssh-connect \
  && curl -fsSL https://raw.githubusercontent.com/bpidperygora/SSH-profile-manager/main/install.sh \
  | GITHUB_REPO=bpidperygora/SSH-profile-manager bash -s -- --bin-dir=/usr/local/bin --name=ssh-connect
```


