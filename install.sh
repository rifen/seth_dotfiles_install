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

# package installs
ARH_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"
DEB_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"
YUM_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"
MAC_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"
BSD_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"
BRW_PACKAGE_NAME="stow zsh git python3 whois unzip gcc make awless awscli xclip sshpass"

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
  ## Check to see if the dotfiles repo is already there.
  if [[ -d $HOME/dotfiles ]]; then
    echo -e "Your dotfiles are already installed"
    program_installs
    exit
  fi

  eval $(ssh-agent -s)
  ssh-add $HOME/.ssh/id_rsa
  echo -e "Successfully Configured Git..."
  echo -e "Backing up current bash configuration...to ${BACKUP_DIR}"
  mkdir $BACKUP_DIR
  sudo mv -v $HOME/.bash* $BACKUP_DIR && mv -v $HOME/.profile $BACKUP_DIR
  cd $HOME
  git clone git@github.com:rifen/dotfiles.git
  if ! [[ -d $HOME/Downloads ]]; then
    mkdir $HOME/Downloads
    echo -e "Added $HOME/Downloads folder... "
  fi
  if ! [[ -d $HOME/Proj* ]]; then
    mkdir $HOME/Projects
    echo -e "Added $HOME/Projects folder... "
  fi
  if ! [[ -d $HOME/Other_Repos ]]; then
    mkdir $HOME/Other_Repos
    echo -e "Added $HOME/Other_Repos folder... "
  fi 
  if ! [[ -d $HOME/virtualenv ]]; then
    mkdir $HOME/virtualenvs
    echo -e "Added $HOME/virtualenv... "
  fi
  cd $HOME/dotfiles
  # For Amazon Linux or a Linux that doesn't have stow in their distribution repository.
  if ! [ -x "$(command -v stow)" &> /dev/null ]; then
    echo "Stow isn't installed. Going to compile from source."
    cd $HOME/Downloads
    curl -o stow-latest.tar.gz https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
    tar -xvpzf stow-latest.tar.gz
    cd stow-2*
    ./configure
    make
    sudo make install
    cd $HOME/dotfiles
  fi
  stow bash git vim zsh
  program_installs
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

program_installs() {
  tfinstall
  bwinstall
}

tfinstall() {
    if ! [ -x "$(command -v terraform)" &> /dev/null ]; then
        read -r -p "Do you want to install Terraform? (y/n) " response
        response=${response,,}
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            read -r -p "Enter the version of Terraform(eg. 0.12.28): " version
            cd Downloads
            echo "Installing terraform ${version} ..."
            curl -o terraform_${version}_linux_amd64.zip https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
            sudo unzip terraform_${version}_linux_amd64.zip -d /usr/bin
        fi
    fi
}

bwinstall() {
    if ! [ -x "$(command -v bw)" &> /dev/null ]; then
        read -r -p "Do you want to install BitWarden? (y/n) " response
        response=${response,,}
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            read -r -p "Enter the version of Bitwarden https://github.com/bitwarden/cli/releases (eg. 1.17.1): " version
            cd Downloads
            echo "Installing bitwarden ${version} ..."
            curl -O -L "https://github.com/bitwarden/cli/releases/download/v${version}/bw-linux-${version}.zip"
            sudo unzip bw-linux-${version}.zip -d /usr/bin
            sudo chmod +x /usr/bin/bw
            # Zinit Completions
            bw completion --shell zsh > ~/.zinit/completions/_bw
            zinit creinstall ~/.zinit/completions
        fi
    fi
}

###########
## LOGIC ##
###########
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${YELLOW}          Rifen Zsh Setup                ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${YELLOW}               Downloads               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  RELEASE=$(cat /etc/*release | grep ^NAME)

  if [[ "$RELEASE" == *"CentOS"* ]]; then
    yum_install
  elif [[ "$RELEASE" == *"Red Hat"* ]]; then
    yum_install
  elif [[ "$RELEASE" == *"Amazon Linux"* ]]; then
    yum_install
  elif [[ "$RELEASE" == *"Ubuntu"* ]]; then
    deb_install
  elif [[ "$RELEASE" == *"Debian GNU/Linux"* ]]; then
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
echo -e "${YELLOW}     Updated/Installed Packages               ${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"

echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e "${YELLOW}          Applying Settings               ${RESET}"
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
