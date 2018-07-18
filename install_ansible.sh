#!/bin/bash

PLATFORM=`uname -s`

if [[ "$PLATFORM" == 'Darwin' ]]; then
	sudo pip install ansible
fi