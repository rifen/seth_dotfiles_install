#!/bin/bash

#backslash-escape colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE='\033[0;37m'
RESET='\033[0m'

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Rifen Zsh Setup                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
set -e

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Downloads               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
ARH_RELEASE="arch\|Manjaro\|Chakra"
DEB_RELEASE="[Dd]ebian\|Knoppix"
YUM_RELEASE="rhel\|CentOS\|RED\|Fedora"

ARH_PACKAGE_NAME="stow zsh git python"
DEB_PACKAGE_NAME="stow zsh git python"
YUM_PACKAGE_NAME="stow zsh git python"
MAC_PACKAGE_NAME="stow zsh git python"
BSD_PACKAGE_NAME="stow zsh git python"
BRW_PACKAGE_NAME="stow zsh git python"

arh_install() {
  sudo pacman -Sy
  yes | sudo pacman -S $ARH_PACKAGE_NAME
}
deb_install() {
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y $DEB_PACKAGE_NAME
}
yum_install() {
  #sudo yum check-update ##BUG: Return from Fedora??
  sudo yum update -y
  sudo yum install -y $YUM_PACKAGE_NAME
}
mac_install() {
  brew update
  brew cask install xquartz
  brew install $MAC_PACKAGE_NAME
}
bsd_install() {
  sudo pkg update
  sudo pkg install -y $BSD_PACKAGE_NAME
}

set_brew() {
  if ! [ -x "$(command -v brew)" ]; then
    echo -e "Now, Install Brew." >&2
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

      if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin/"
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH
    fi
  fi
  {
    brew install $BRW_PACKAGE_NAME
  } || {
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    brew vendor-install ruby
    brew install $BRW_PACKAGE_NAME
  }
  $(brew --prefix)/opt/fzf/install
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  RELEASE=$(cat /etc/*release)

  ##ARH Package
  if echo -e $RELEASE | grep ^NAME | grep Manjaro; then
    arh_install
  elif echo -e $RELEASE | grep ^NAME | grep Chakra; then
    arh_install
  elif echo -e $RELEASE | grep ^ID | grep arch; then
    arh_install
  elif echo -e $RELEASE | grep ^ID_LIKE | grep arch; then
    arh_install

  ##Deb Package
  elif echo -e $RELEASE | grep ^NAME | grep Ubuntu; then
    deb_install
  elif echo -e $RELEASE | grep ^NAME | grep Debian; then
    deb_install
  elif echo -e $RELEASE | grep ^NAME | grep Mint; then
    deb_install
  elif echo -e $RELEASE | grep ^NAME | grep Knoppix; then
    deb_install
  elif echo -e $RELEASE | grep ^ID_LIKE | grep debian; then
    deb_install

  ##Yum Package
  elif echo -e $RELEASE | grep ^NAME | grep CentOS; then
    yum_install
  elif echo -e $RELEASE | grep ^NAME | grep Red; then
    yum_install
  elif echo -e $RELEASE | grep ^NAME | grep Fedora; then
    yum_install
  elif echo -e $RELEASE | grep ^ID_LIKE | grep rhel; then
    yum_install

  else
    echo -e "----------------------------------------"
    echo -e "${RED}OS NOT DETECTED${RESET}, couldn't install packages."
    echo -e "----------------------------------------"
    exit 1
  fi
fi
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Applying Settings               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
## Generate SSH key for GitHub
ssh-keygen -t rsa -b 4096 -C "seth.a.gehring@gmail.com" &
wait
cd ~/.ssh && vim id_rsa.pub
wait
echo -e -en "Did you copy and paste into https://github.com/settings/keys ??? (y/n)"
read -r option
if [$option == "y"]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
  sudo mv -v ~/.bash* ~/*.bak && mv ~/.profile ~/.profile.bak
  cd ~ && git clone git@github.com:rifen/dotfiles.git && cd dotfiles && stow bash git vim zsh && cd ~
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
else
  echo -e "${RED}No Github Config - This is a private repo${RESET}"
  exit
fi
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${GREEN}          FIN                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
