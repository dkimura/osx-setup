# OSX Setup

## Software Update

```bash
sudo softwareupdate --install --recommended
```

## Install Xcode

```bash
xcode-select --install
```

## Install Homebrew

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Clone this repository

```bash
git clone git@github.com:dkimura/osx-setup.git
```

## Run Ansible

```bash
brew update
brew install ansible
ansible-playbook localhost.yml --ask-become-pass
```
