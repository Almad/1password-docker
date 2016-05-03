#!/bin/bash
AGILECHAIN_LOCATION="$HOME/Dropbox/1Password.agilekeychain"
if [ -f ./.env ]; then
	. ./.env
fi

docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v "$AGILECHAIN_LOCATION:/wine/drive_c/users/root/My Documents/1Password.agilekeychain" --net="host"  --name 1password 1password bash
