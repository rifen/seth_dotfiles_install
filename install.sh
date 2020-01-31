#!/bin/bash
echo "----------------------------------------"
echo "          Rifen Zsh Setup                "
echo "----------------------------------------"
trap 'do_something' ERR

echo ""
echo "--------------------"
echo "  Downloads"
echo ""
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
    echo "Now, Install Brew." >&2
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
  if echo $RELEASE | grep ^NAME | grep Manjaro; then
    arh_install
  elif echo $RELEASE | grep ^NAME | grep Chakra; then
    arh_install
  elif echo $RELEASE | grep ^ID | grep arch; then
    arh_install
  elif echo $RELEASE | grep ^ID_LIKE | grep arch; then
    arh_install

  ##Deb Package
  elif echo $RELEASE | grep ^NAME | grep Ubuntu; then
    deb_install
  elif echo $RELEASE | grep ^NAME | grep Debian; then
    deb_install
  elif echo $RELEASE | grep ^NAME | grep Mint; then
    deb_install
  elif echo $RELEASE | grep ^NAME | grep Knoppix; then
    deb_install
  elif echo $RELEASE | grep ^ID_LIKE | grep debian; then
    deb_install

  ##Yum Package
  elif echo $RELEASE | grep ^NAME | grep CentOS; then
    yum_install
  elif echo $RELEASE | grep ^NAME | grep Red; then
    yum_install
  elif echo $RELEASE | grep ^NAME | grep Fedora; then
    yum_install
  elif echo $RELEASE | grep ^ID_LIKE | grep rhel; then
    yum_install

  else
    echo "OS NOT DETECTED, try to flexible mode.."
    if
      echo $RELEASE | grep $ARH_RELEASE 2 >/dev/null &
      1
    then
      arh_install
    elif
      echo $RELEASE | grep $DEB_RELEASE 2 >/dev/null &
      1
    then
      deb_install
    elif
      echo $RELEASE | grep $YUM_RELEASE 2 >/dev/null &
      1
    then
      yum_install
    fi
  fi
  set_brew
elif [[ "$OSTYPE" == "darwin"* ]]; then
  set_brew
  mac_install
elif [[ "$OSTYPE" == "FreeBSD"* ]]; then
  bsd_install
elif uname -a | grep FreeBSD; then
  bsd_install
else
  echo "OS NOT DETECTED, couldn't install packages."
  exit 1
fi

echo "--------------------"
echo "  Apply Settings"
echo ""
## Generate SSH key for GitHub
ssh-keygen -t rsa -b 4096 -C "seth.a.gehring@gmail.com" &
wait
cd ~/.ssh && vim id_rsa.pub
wait
echo -en "Did you copy and paste into https://github.com/settings/keys ??? (y/n)"
read -r option
if [$option == "y"]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
  sudo mv -v ~/.bash* ~/*.bak && mv ~/.profile ~/.profile.bak
  cd ~ && git clone git@github.com:rifen/dotfiles.git && cd dotfiles && stow bash git vim zsh && cd ~
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
else
  echo "No Github Config - This is a private repo"
  exit
fi
echo "      The END       "
echo "--------------------"
