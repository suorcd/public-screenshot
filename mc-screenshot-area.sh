#!/bin/bash

DATE=$(date +'%Y%m%d%H%M%S')
FIL="$(echo "${DATE}${RANDOM}" | sha256sum - | awk '{print $1}').png"
MCSRV="finl"
SRV="files.example.us"
RFIL="gnp/${FIL}"
FILEURL="https://${SRV}/${RFIL}"

cd "${HOME}/Pictures" || ( echo -n "Couldn't 'cd' into ~/Pictures" | xclip -selection c && exit 1 )
gnome-screenshot -a --file="${FIL}"

# mc - minio client
${HOME}/bin/mc cp "${HOME}/Pictures/${FIL}" "${MCSRV}/${RFIL}"
echo -n "${FILEURL}" | xclip -selection c
