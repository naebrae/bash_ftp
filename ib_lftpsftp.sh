#!/bin/bash
# Secure-FTP (sftp) transfer using lftp.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/inbound/"
REMFIL="*"
REMURL="sftp://ftp.lab.home"
REMDIR="TST/outbound/"
# USRPWD needs to be user,pass. lftp will not ask for a password
USRPWD="vagrant,vagrant"
# Enable email status report
USEMAIL=1
EMAIL="vagrant@localhost"

if [ ! -d ~/.lftp ]
then
  mkdir ~/.lftp
fi

if [ -f ~/.lftp/transfer_log ]
then
  rm -f ~/.lftp/transfer_log
fi

/usr/bin/lftp <<EndLFTP
set xfer:clobber yes
set net:timeout 10
set net:max-retries 2
set net:reconnect-interval-base 5
lcd "$LOCDIR"
open "$REMURL" -u "$USRPWD"
cd "$REMDIR"
mget "$REMFIL"
close -a
EndLFTP

if [ ${USEMAIL} -eq 1 ]; then
  if [ -f ~/.lftp/transfer_log ]; then
    echo "Transfer log for $REMURL/$REMDIR to $LOCDIR attached" | /usr/bin/mutt -s "Transfer Status" -a ~/.lftp/transfer_log -- $EMAIL
    rm -f ~/.lftp/transfer_log
  else
    echo "Transfer log for $REMURL/$REMDIR to $LOCDIR wasn't created" | /usr/bin/mutt -s "Transfer Status" $EMAIL
  fi
fi

