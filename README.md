# OSX Setup

## Software Update

```
$ sudo softwareupdate --install --recommended
```

## Install Xcode

```
$ xcode-select --install
```

## Install Homebrew

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Clone this repository

```
$ git clone git@github.com:dkimura/osx-setup.git
```

## Run Ansible

```
$ brew update
$ brew install ansible
$ ansible-playbook site.yml -vvvv
```
