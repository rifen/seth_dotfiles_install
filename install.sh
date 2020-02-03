#!/bin/bash -xv

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

# package installs
ARH_PACKAGE_NAME="stow zsh git python"
DEB_PACKAGE_NAME="stow zsh git python"
YUM_PACKAGE_NAME="stow zsh git python"
MAC_PACKAGE_NAME="stow zsh git python"
BSD_PACKAGE_NAME="stow zsh git python"
BRW_PACKAGE_NAME="stow zsh git python"

#Converts responses to lowercase and stores the variable
response=${response,,}

#Back folder for old things
BACKUP_DIR="$HOME/.backup"

#Current Github email account
GITHUB_EMAIL="seth.a.gehring@gmail.com"

################
## FUNCTIONS ##
################
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

install_dotfiles() {
  ## Installs dotfiles
  clear
  eval $(ssh-agent -s)
  ssh-add $HOME/.ssh/id_rsa
  echo -e "Successfully Configured Git..."
  echo -e "Backing up current bash configuration...to ${BACKUP_DIR}"
  mkdir $BACKUP_DIR
  sudo mv -v $HOME/.bash* $BACKUP_DIR && mv -v $HOME/.profile $BACKUP_DIR
  cd $HOME
  git clone git@github.com:rifen/dotfiles.git
  cd $HOME/dotfiles
  stow bash git vim zsh
  cd $HOME
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
  exec zsh
}

gen_key() {
  ## Generate SSH key for GitHub
  clear
  ssh-keygen -t rsa -b 4096 -C "${GITHUB_EMAIL}"
  echo -e "\n "
  echo -en "Public Key:"
  echo -e "\n "
  cat ~/.ssh/id_rsa.pub
  echo -e "\n "

  ## Check for Git Configuration
  echo -e "${RED}Did you copy and paste into${RESET}${YELLOW} https://github.com/settings/keys${RESET}${RED} ??? ${RESET}"
  echo -e "OR is Github already configured for this box?"
  read -r -p " (y/n) " response
  response=${response,,} # tolower
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    :
  else
    exit 1
  fi
}

###########
## LOGIC ##
###########
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Rifen Zsh Setup                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}               Downloads               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  RELEASE=$(cat /etc/*release | grep ^NAME)

  if [[ "$RELEASE" == *"CentOS"* ]]; then
    yum_install
  elif [[ "$RELEASE" == *"Red Hat"* ]]; then
    yum_install
  elif [[ "$RELEASE" == *"Ubuntu"* ]]; then
    deb_install
  else
    echo -e "----------------------------------------"
    echo -e "${RED}OS NOT DETECTED${RESET}"
    echo -e "${RELEASE} was detected"
    echo -e "Exiting...."
    echo -e "----------------------------------------"
    exit 1
  fi
fi
clear
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}     Updated/Installed Packages               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${BLUE}          Applying Settings               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"

## Look for id_rsa to see if it already exists and run gen_key or dotfiles
echo -en "Checking for id_rsa...."

if ! [[ -f $HOME/.ssh/id_rsa ]]; then
  echo -e "Did not find id_rsa (private) key. "
  gen_key
  install_dotfiles
fi

if [[ -f $HOME/.ssh/id_rsa ]]; then
  echo -e "Found an id_rsa (private) key. "
  read -r -p "Do you want to backup the key? (y/n) " response
fi

if [[ "$response" =~ ^(yes|y)$ ]]; then
  echo -e "Making a backup of the keys..."
  cp $HOME/.ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub.old
  cp $HOME/.ssh/id_rsa $HOME/.ssh/id_rsa.old
fi

read -r -p "Do you want to generate a new key?" response

if [[ "$response" =~ ^(yes|y)$ ]]; then
  gen_key
fi

read -r -p "Assuming you have Github configured do you want to install the dotfiles? (y/n)" response

if [[ "$response" =~ ^(yes|y)$ ]]; then
  install_dotfiles
else
  echo -e "${RED}No Github Config - This is a private repo${RESET} \nOR you just don't want to install the dotfiles."
fi

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${GREEN}                    FIN                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
