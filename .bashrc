#!/usr/bin/env bash
iatest=$(expr index "$-" i)

# if [ -f /usr/bin/fastfetch ]; then
# 	fastfetch
# fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#######################################################
# EXPORTS
#######################################################

export TERMINAL="alacritty"
export EDITOR="nvim"
export VISUAL="nvim"
# export MANPAGER="nvim +Man!"

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style none"; fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T " # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND='history -a'

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Custom Desaturated PS1 Prompt
PS1='\[\e[38;5;109m\]\u\[\e[38;5;243m\]@\[\e[38;5;208m\]\h\[\e[38;5;243m\]:\[\e[38;5;142m\]\w\[\e[0m\]\$ '

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# config files backup (bare git repo)
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# open my quick note file
alias note='nvim ~/Documents/notes.md'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias ls='ls -aFh --color=always' # add colors and file type extensions

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Search command line history
alias h='history | grep '

# Search running processes
alias p='ps aux | grep '
alias topcpu='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'

# Shutdown/Restart
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'

# Tools 
alias thunar='thunar . & disown'

# General aliases
alias clean-nvim='rm -rf ~/{.cache/nvim/,.local/state/nvim/,.local/share/nvim/,.config/nvim/nvim-pack-lock.json}'

# Temp aliases
alias cd-dev='cd /mnt/work/nader_data/development/'
alias cd-arch='cd /mnt/work/nader_data/archive/personal/'
#######################################################
# SPECIAL FUNCTIONS
#######################################################
# pkg utilties
pkg() {
  local LOG_FILE="$HOME/.config/pkg.md"
  mkdir -p "$(dirname "$LOG_FILE")"

  case "$1" in
    install)
      shift
      sudo apt install "$@" && {
        for pkg in "$@"; do
          grep -qxF "$pkg" "$LOG_FILE" || echo "$pkg" >> "$LOG_FILE"
        done
      }
      ;;
    remove)
      shift
      sudo apt purge --autoremove "$@" && {
        for pkg in "$@"; do
          sed -i "/^$pkg$/d" "$LOG_FILE"
        done
      }
      ;;
    update)
      shift
      echo "--- Updating System Packages (apt) ---"
      # Refreshing indexes first, then upgrading with a manual prompt
      sudo apt update && sudo apt upgrade
      echo -e "\n--- Updating Node Packages (npm) ---"
      # npm update is generally interactive/safe
      sudo npm -g update
      ;;
    list)
      [ -s "$LOG_FILE" ] && cat "$LOG_FILE" || echo "Log is empty."
      ;;
    *)
      echo "Usage: pkg {install|remove|update|list} [package...]"
      ;;
  esac
}
