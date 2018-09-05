#!/bin/bash
set -e

PLATFORM=`uname -s`

if [[ "$PLATFORM" == 'Darwin' ]]; then
    if [ ! -x "$(command -v brew)" ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    sudo chown -R $(whoami) $(brew --prefix)/*
    brew update
    brew install ansible
fi
