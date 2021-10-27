#!/bin/bash


source ./public-screenshot.env


cd ${LPATH} || ( echo -n "Couldn't 'cd' into ~/Pictures" | ${COPYCMD} && exit 1 )
spectacle -b --output="${LPATH}/${FIL}"

rsync "${LPATH}/${FIL}" ${SSHSRV}:"${RFIL}" || ( echo -n "Rsync failed!!" | ${COPYCMD} && exit 1 )
echo -n "${FILEURL}" | ${COPYCMD}

exit 0
