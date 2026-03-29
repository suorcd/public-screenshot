#!/bin/bash

DATE=$(date +%s)
fil_name="$(echo "${DATE}${RANDOM}" | sha256sum | (
	read -ra fil_ar
	echo "${fil_ar[0]}"
))"
FIL_EXTENSION='png'
FIL="${fil_name}.${FIL_EXTENSION}"

# shellcheck source=./public-screenshot.env
. ./public-screenshot.env

REMOTEFILE="${REMOTEPATH}/${FIL}"
FILEURL="https://${SRV}${SRVPATH}/${FIL}"

case $XDG_SESSION_TYPE in
'wayland')
	COPYCMD='wl-copy'
	;;
'x11')
	COPYCMD='xsel -i'
	;;
*)
	exit 255
	;;
esac

cd "${LOCALPATH}" || (echo -n "Couldn't 'cd' into ${LOCALPATH}" | ${COPYCMD} && exit 1)
flameshot screen -p "${LOCALPATH}"

rsync "${LOCALPATH}/${FIL}" "${SSHSRV}":"${REMOTEFILE}" || (echo -n "Rsync failed!!" | ${COPYCMD} && exit 1)
echo -n "${FILEURL}" | ${COPYCMD}
[[ ${DENOTIFY:-} ]] && ${DENOTIFY} "${FILEURL}"

exit 0
