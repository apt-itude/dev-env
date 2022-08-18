#!/bin/bash
set -e

PLATFORM=`uname -s`

if [[ "$PLATFORM" == 'Darwin' ]]; then
    if [ ! -x "$(command -v brew)" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install ansible
fi
