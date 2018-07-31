#!/bin/bash

PLATFORM=`uname -s`

if [[ "$PLATFORM" == 'Darwin' ]]; then
    sudo chown -R $USER /usr/local/
    if [ ! -x "$(command -v brew)" ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew update
    brew install ansible
fi
