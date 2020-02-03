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

if [[ -d $HOME/.oh-my-zsh ]]; then
    uninstall_oh_my_zsh
    echo -e "Removed oh-my-zsh..."
else
    echo -e "Oh-My-Zsh isn't installed..."
fi

if [[ -d $HOME/.fzf ]]; then
    $HOME/.fzf/
    . uninstall
    echo -e "Removed .fzf"
else
    echo -e "Fzf isn't installed..."
fi

if [[ -d $HOME/.zinit ]]; then
    rm -rf $HOME/.zinit
    echo -e "Removed .zinit directory..."
else
    echo -e "Zinit isn't installed..."
fi

if [[ -d $HOME/.zshenv ]]; then
    rm -rf $HOME/.zshenv
    echo -e "Removed .zshenv directory..."
else
    echo -e "Zshenv isn't installed..."
fi

if [[ -d $HOME/dotfiles ]]; then
    cd $HOME/dotfiles
    echo -e "Stowing Bash/Git/Vim/Zsh configs..."
    stow -D bash git vim zsh
    cd $HOME
    rm -rf $HOME/dotfiles
    echo -e "Removed dotfiles directory..."
else
    echo -e "Your dotfiles aren't installed..."
fi

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}               Uninstalled               ${RESET}"
echo -e "${BLUE}    Old dotfiles are in .backup               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
