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
    SCREENSHOTCMD='spectacle -b -n --output='
    COPYCMD='wl-copy'
    ;;
  'plasmaX')
    SCREENSHOTCMD='spectacle -b --output='
    COPYCMD='xsel -i'
    ;;
  'gnomewayland')
    SCREENSHOTCMD='gnome-screenshot --file='
    COPYCMD='xsel -i'
    ;;
  'gnomewayX')
    SCREENSHOTCMD='gnome-screenshot --file='
    COPYCMD='wl-copy'
    ;;    
  *)
    exit 255
    ;;
esac

cd "${LOCALPATH}" || ( echo -n "Couldn't 'cd' into ${LOCALPATH}" | ${COPYCMD} && exit 1 )
"${SCREENSHOTCMD}""${LOCALPATH}"/"${FIL}"

rsync "${LOCALPATH}/${FIL}" ${SSHSRV}:"${REMOTEFILE}" || ( echo -n "Rsync failed!!" | ${COPYCMD} && exit 1 )
echo -n "${FILEURL}" | ${COPYCMD}

exit 0
