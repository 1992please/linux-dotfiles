# My Dotfiles (Bare Repo Method)

Managed with a bare git repository: `~/.dotfiles` holds the git data and `$HOME` is the work tree, so no symlinks are needed. The `dotfiles` alias (defined in `.bashrc`) is used like `git`.

- `~/.config/pkg.md` lists the programs this setup should have. Most come from apt, the rest are under [Manual installs](#4-manual-installs). The `pkg install` / `pkg remove` functions in `.bashrc` keep it up to date.
- Settings made through GUI dialogs or specific to this machine are not tracked. They are written down under [Desktop settings](#6-desktop-settings) instead.

## Before Reinstalling
- Commit and push everything: `dotfiles status`, then `dotfiles push`.
- Back up what is not in this repo:
  - `~/.ssh` keys (or make new ones later)
  - the BitLocker `.key` file (see [Bitlocker decryption](#bitlocker-decryption)). **Never commit it here, this repo is public.**
  - personal files such as `~/Documents`

## Fresh Install

### 1. Enable contrib and non-free
`nvidia-driver` needs them. `sudoedit /etc/apt/sources.list` so the lines read (same for the `deb-src` lines):
```
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
```
Then `sudo apt update`.

### 2. Restore the dotfiles
```bash
sudo apt install git
git clone --bare https://github.com/1992please/linux-dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```
If checkout refuses because files already exist, they are Debian's defaults (e.g. `~/.bashrc`). Check the list it prints, then overwrite them:
```bash
dotfiles checkout -f
source ~/.bashrc
```
Pushing needs an SSH key, see [step 7](#7-final-steps).

### 3. Install programs
Go through `~/.config/pkg.md` and install the entries with apt. These are the exceptions, covered in [Manual installs](#4-manual-installs): `neovim`, `tree-sitter-cli`, `google-chrome-stable`, `code`, `localsend`.

Install `nvidia-driver` together with the kernel headers so DKMS can build the module, then reboot:
```bash
sudo apt install linux-headers-amd64 nvidia-driver
```

### 4. Manual installs

#### Neovim
Debian's `neovim` is too old: the config uses `vim.pack`, which needs Neovim 0.12+. Build it into `/usr/local` (the build dependencies are in `pkg.md` under Build / Development):
```bash
git clone https://github.com/neovim/neovim ~/neovim && cd ~/neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install
```

#### Global npm packages
`tree-sitter-cli` is used by nvim-treesitter, `neovim` is the Node host for Neovim plugins:
```bash
sudo npm install -g tree-sitter-cli neovim
```

#### JetBrains Mono Nerd Font
Used by i3, polybar, alacritty and the GTK theme. Without it polybar icons show as boxes.
```bash
mkdir -p ~/.local/share/fonts/JetBrainsMono
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C ~/.local/share/fonts/JetBrainsMono
fc-cache -f
```

#### Vulkan SDK
Download the Linux tarball from https://vulkan.lunarg.com/sdk/home (last used: 1.4.350.1), extract it to `/opt/vulkansdk` and point `default` at it. `.bashrc` sources `/opt/vulkansdk/default/setup-env.sh` when it exists.
```bash
sudo mkdir -p /opt/vulkansdk && sudo chown $USER: /opt/vulkansdk
tar -xf ~/Downloads/vulkansdk-linux-x86_64-*.tar.* -C /opt/vulkansdk
ln -sfn <version> /opt/vulkansdk/default
```

#### Google Chrome, VS Code, LocalSend
Not in Debian's repos. Download each `.deb` and install it with `sudo apt install ./<file>.deb`. Chrome and VS Code add their own apt repo (VS Code asks first), so they update with apt. LocalSend doesn't, so update it by hand.
- Chrome: https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
- VS Code: https://code.visualstudio.com/download
- LocalSend: https://github.com/localsend/localsend/releases/latest

#### Claude Code
```bash
curl -fsSL https://claude.ai/install.sh | bash
```
Its settings and status line script in `~/.claude/` are already restored by the checkout.

### 5. System settings
- **Disks:** add the `fstab` (and `crypttab` for BitLocker) entries from [Side Notes](#side-notes).
- **LightDM autologin:** `sudoedit /etc/lightdm/lightdm.conf` and set under `[Seat:*]`:
  ```
  autologin-user=nader
  autologin-user-timeout=0
  ```

### 6. Desktop settings
These were set through GUIs or are specific to this machine, so they are noted here instead of tracked.

#### Screen scaling
`~/.Xresources` is loaded at login and scales X apps to 150% for this monitor:
```bash
cat > ~/.Xresources <<'EOF'
Xft.dpi: 144
Xcursor.size: 40
EOF
```

#### GTK theme (lxappearance)
- Widget: `Adwaita-dark` (from `gnome-themes-extra`)
- Icon theme: `Papirus-Dark`
- Default font: `JetBrainsMonoNL Nerd Font Propo 10`

#### Default applications
```bash
xdg-settings set default-web-browser google-chrome.desktop
xdg-mime default google-chrome.desktop application/pdf
xdg-mime default com.microsoft.VSCode.desktop text/plain text/markdown application/xml
xdg-mime default nvim.desktop text/x-python text/x-cmake application/x-bat
xdg-mime default nsxiv.desktop image/png image/jpeg
```

#### Thunar
- **Preferred terminal**, used by "Open Terminal Here":
  ```bash
  mkdir -p ~/.config/xfce4 && echo 'TerminalEmulator=alacritty' > ~/.config/xfce4/helpers.rc
  ```
- **Custom actions** (Edit → Configure custom actions…):

  | Name | Command | Icon | Appears if selection contains |
  |---|---|---|---|
  | Open Terminal Here | `exo-open --working-directory %f --launch TerminalEmulator` | utilities-terminal | Directories |
  | Open VSCode | `code .` | vscode | Directories |

  Open Terminal Here ships with Thunar. Give it the keyboard shortcut **Shift+!**.
- **View preferences.** Run these with Thunar closed, otherwise it overwrites them when it exits:
  ```bash
  thunar -q
  xfconf-query -c thunar -n -p /last-view -t string -s ThunarDetailsView
  xfconf-query -c thunar -n -p /last-details-view-zoom-level -t string -s THUNAR_ZOOM_LEVEL_75_PERCENT
  xfconf-query -c thunar -n -p /last-show-hidden -t bool -s true
  xfconf-query -c thunar -n -p /last-menubar-visible -t bool -s false
  xfconf-query -c thunar -n -p /last-image-preview-visible -t bool -s true
  xfconf-query -c thunar -n -p /misc-image-preview-mode -t string -s THUNAR_IMAGE_PREVIEW_MODE_EMBEDDED
  xfconf-query -c thunar -n -p /misc-expandable-folders -t bool -s true
  xfconf-query -c thunar -n -p /shortcuts-icon-size -t string -s THUNAR_ICON_SIZE_48
  xfconf-query -c thunar -n -p /tree-icon-size -t string -s THUNAR_ICON_SIZE_24
  ```
- **Sidebar bookmark** (after the disks are mounted):
  ```bash
  mkdir -p ~/.config/gtk-3.0 && echo 'file:///mnt/work/nader_data' >> ~/.config/gtk-3.0/bookmarks
  ```

### 7. Final steps

#### SSH key and push access
Restore the backed-up `~/.ssh` (private keys need `chmod 600`), or make a new key and add the `.pub` file at https://github.com/settings/keys:
```bash
ssh-keygen -t ed25519
```
Then switch the repo to SSH and set up upstream tracking (a bare clone has neither):
```bash
dotfiles remote set-url origin git@github.com:1992please/linux-dotfiles.git
dotfiles config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
dotfiles fetch
dotfiles branch -u origin/master
```

#### Neovim language servers
Start `nvim` once so `vim.pack` installs the plugins, then run:
```
:MasonInstall clangd codelldb glsl_analyzer lua-language-server neocmakelsp pyright
```


# Side Notes
## Mounting Hard Disks
you can use either `lsblk -f` or `sudo blkid` to see the UUID of a hard disk
you can use `mount` to see all mounted drives on the system
you can use `id` to see the current user uid and gid
sudoedit `/etc/fstab` file and add to it
### Mounting internal Hard Disk
`UUID=285CA16D5CA1370A /mnt/work ntfs3 defaults,uid=1000,gid=1000,dmask=022,fmask=133,nofail 0 0`
dmask and fmask is for giving folders and files 755 and 644 Mode access instead of 777 and 666
nofail so that the operating system won't fail to start up if the disk couldn't be mounted
### Mounting external Hard Disk
`UUID=2192F4311FD9045B /mnt/backup ntfs3 defaults,noauto 0 0`
noauto to make sure it doesn't auto mount when we startup the system
### Bitlocker decryption
Put your .key file anywhere you want for example `/etc/cryptsetup-keys/work.key`
and add in file `/etc/crypttab`
`work_decrypted UUID=1eab0b79-141c-49ab-a324-2d3749aa600a /etc/cryptsetup-keys/work.key bitlk`
now we should change the fstab file load the work_decrypted mount point in `/dev/mapper/work_decrypted`
`/dev/mapper/work_decrypted /mnt/work ntfs3 defaults,uid=1000,gid=1000,dmask=022,fmask=133,nofail 0 0`
