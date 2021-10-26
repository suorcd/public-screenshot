#!/bin/bash


source ./public-screenshot.env


cd "${HOME}/Pictures" || ( echo -n "Couldn't 'cd' into ~/Pictures" | xclip -selection c && exit 1 )
gnome-screenshot --file="${FIL}"

rsync "${HOME}/Pictures/${FIL}" ${SSHSRV}:"${RFIL}" || ( echo -n "Rsync failed!!" | xclip -selection c && exit 1 )
echo -n "${FILEURL}" | xclip -selection c
