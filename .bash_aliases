################## Aliases ###################
# config files backup (bare git repo)
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

################## Functions ###################
# pkg utilties
pkg() {
    local LOG_FILE="$HOME/.config/pkg_list.txt"
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

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
            sudo apt remove --purge "$@" && {
                for pkg in "$@"; do
                    sed -i "/^$pkg$/d" "$LOG_FILE"
                done
            }
            ;;
	list)
            [ -s "$LOG_FILE" ] && cat "$LOG_FILE" || echo "Log is empty."
            ;;
        *)
            echo "Usage: pkg {install|remove|show-installed} [package...]"
            ;;
    esac
}
