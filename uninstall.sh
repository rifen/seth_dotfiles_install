#!/bin/bash

################
## VARIABLES ##
################

# backslash-escape colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'

$HOME/.fzf/
. uninstall
echo -e "Removed .fzf"

rm -rf $HOME/.zinit
echo -e "Removed .zinit directory..."

cd $HOME/dotfiles
echo -e "Stowing Bash/Git/Vim/Zsh configs..."
stow -D bash git vim zsh

if [[ -d dotfiles ]]; then
    rm -rf dotfiles
fi

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Uninstalled                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
