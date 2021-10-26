#!/bin/bash

DATE=$(date +'%Y%m%d%H%M%S')
FIL="$(echo "${DATE}${RANDOM}" | sha256sum - | awk '{print $1}').png"
SSHSRV="gaz"
SRV="files.example.com"
RFIL="/srv/example/srv/$SRV/$FIL"
FILEURL="https://$SRV/$FIL"
RFIL="/srv/${SRV}/${FIL}"
FILEURL="https://${SRV}/${FIL}"

cd "${HOME}/Pictures" || ( echo -n "Couldn't 'cd' into ~/Pictures" | xclip -selection c && exit 1 )
gnome-screenshot --file="${FIL}"

rsync "${HOME}/Pictures/${FIL}" ${SSHSRV}:"${RFIL}" || ( echo -n "Rsync failed!!" | xclip -selection c && exit 1 )
echo -n "${FILEURL}" | xclip -selection c
