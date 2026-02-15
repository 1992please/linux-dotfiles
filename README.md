# My Fedora Dotfiles (Bare Repo Method)

Managed with a bare git repository. No symlinks required.

## Quick Setup on a Fresh Install
On a new machine, run these commands to restore all settings:

1. **Alias the command:**
   alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

2. **Clone the repo:**
   git clone --bare <YOUR_GITHUB_REPO_URL> $HOME/.dotfiles

3. **Checkout the files:**
   config checkout

4. **Set the config for this machine:**
   config config --local status.showUntrackedFiles no

*Note: If checkout fails due to existing default files, move them to a backup folder first.*
