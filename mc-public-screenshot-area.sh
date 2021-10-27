#!/bin/bash

DATE=$(date +%s)
FIL_NAME=($(echo "${DATE}${RANDOM}" | sha256sum))
FIL_EXTENSION='png'
FIL=${FIL_NAME:0}.${FIL_EXTENSION}

source ./public-screenshot.env

REMOTEFILE="${REMOTEPATH}/${FIL}"
FILEURL="https://${SRV}${SRVPATH}/${FIL}"

SCREENSHOTCMD=''
COPYCMD=''
case $DESKTOP_SESSION in
  'plasmawayland')
    SCREENSHOTCMD='spectacle -b -n -r -o'
    COPYCMD='wl-copy'
    ;;
  'plasmaX')
    SCREENSHOTCMD='spectacle -b -n -r -o'
    COPYCMD='xsel -i'
    ;;
  'gnomewayland')
    SCREENSHOTCMD='gnome-screenshot -a -f'
    COPYCMD='wl-copy'
    ;;
  'gnomewayX')
    SCREENSHOTCMD='gnome-screenshot -a -f'
    COPYCMD='xsel -i'

    ;;
  *)
    exit 255
    ;;
esac

cd "${LOCALPATH}" || ( echo -n "Couldn't 'cd' into ${LOCALPATH}" | ${COPYCMD} && exit 1 )
${SCREENSHOTCMD} "${LOCALPATH}/${FIL}"

# mc - minio client
${HOME}/bin/mc cp "${HOME}/Pictures/${FIL}" "${MCSRV}/${RFIL}" || ( echo -n "mc failed!!" | ${COPYCMD} && exit 1 )
echo -n "${FILEURL}" | ${COPYCMD}

exit 0
