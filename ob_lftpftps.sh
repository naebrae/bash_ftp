#!/bin/bash
# FTP-Secure (ftps) transfer using lftp.
# Explicit ftps connects to standard ftp port (default: 21) and explicity requests a secured connection.
# Implicit ftps connects to the secure ftp port (default: 990) and ssl is implied by the connection.

LOCDIR="/home/vagrant/outbound/"
LOCFIL="*"
#Explicit
REMURL="ftp://ftp.lab.home:21"
#Implicit 
#REMURL="ftps://ftp.lab.home:990"
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
set xfer:log 1
set ftp:ssl-force yes
set ftp:ssl-protect-data yes
set ftp:use-feat no
set ftp:use-mdtm no
set net:timeout 10
set net:max-retries 2
set net:reconnect-interval-base 5
set ssl:verify-certificate no
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
