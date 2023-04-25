#!/bin/bash
# Secure-FTP (sftp) transfer using lftp.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/outbound/"
LOCFIL="*"
REMURL="sftp://ftp.lab.home"
REMDIR="TST/inbound/"
# USRPWD needs to be user,pass. lftp will not ask for a password
USRPWD="vagrant,vagrant"
# Enable email status report
USEMAIL=1
EMAIL="vagrant@localhost"

files=$(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort)
if [ ${#files} -eq 0 ]; then
    echo "Could not find transfer files exiting ..."
    exit 1
fi

if [ ! -d ~/.lftp ]
then
  mkdir ~/.lftp
fi

if [ -f ~/.lftp/transfer_log ]
then
  rm -f ~/.lftp/transfer_log
fi

/usr/bin/lftp <<EndLFTP
set net:timeout 10
set net:max-retries 2
set net:reconnect-interval-base 5
lcd "$LOCDIR"
open "$REMURL" -u "$USRPWD"
cd "$REMDIR"
mput "$LOCFIL"
close -a
EndLFTP

if [ ${USEMAIL} -eq 1 ]; then
  if [ -f ~/.lftp/transfer_log ]; then
    echo "Transfer log for $LOCDIR to $REMURL$REMDIR attached" | /usr/bin/mutt -s "Transfer Status" -a ~/.lftp/transfer_log -- $EMAIL
    rm -f ~/.lftp/transfer_log
  else
    echo "Transfer log for $LOCDIR to $REMURL$REMDIR wasn't created" | /usr/bin/mutt -s "Transfer Status" $EMAIL
  fi
fi
