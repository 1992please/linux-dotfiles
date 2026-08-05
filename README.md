# My Dotfiles (Bare Repo Method)

Managed with a bare git repository. No symlinks required.

## Quick Setup on a Fresh Install
On a new machine, run these commands to restore all settings:

1. **Alias the command:**
   alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

2. **Clone the repo:**
   git clone --bare https://github.com/1992please/linux-dotfiles.git $HOME/.dotfiles

3. **Checkout the files:**
   dotfiles checkout

4. **Set the config for this machine:**
   dotfiles config --local status.showUntrackedFiles no

*Note: If checkout fails due to existing default files, move them to a backup folder first.*


# Side Notes
## Mounting Hard Disks
you can use either `lsblk -f` or `sudo blkid` to see the UUID of a hard disk
you can use `mount` to see all mounted drives on the system
you can use `id` to see the current user uid and gid
sudoedit `/etc/fstab` file and add to it
### Mounting internal Hard Disk
`UUID=285CA16D5CA1370A /mnt/work ntfs3 defaults,uid=1000,gid=1000,dmask=022,fmask=133,nofail 0 0`
dmask and fmash is for giving folders and files 755 and 644 Mode access instead of 777 and 666
nofail so that the operating system will fail to startup if the disk couldn't be mounted
### Mounting external Hard Disk
`UUID=2192F4311FD9045B /mnt/backup ntfs3 defaults,noauto 0 0`
noauto to make sure it doesn't auto mount when we startup the system
### Bitlocker decryption
Put you .key file anywhere you want for example `/etc/cryptsetup-keys/work.key`
and add in file `/etc/crypttab`
`work_decrypted UUID=1eab0b79-141c-49ab-a324-2d3749aa600a /etc/cryptsetup-keys/work.key bitlk`
now we should change the fstab file load the work_decrypted mount point in `/dev/mapper/work_decrypted`
`/dev/mapper/work_decrypted /mnt/work ntfs3 defaults,uid=1000,gid=1000,dmask=022,fmask=133,nofail 0 0`
