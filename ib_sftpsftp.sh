#!/bin/bash
# Secure-FTP (sftp) transfer using sftp.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/in bound/"
REMFIL="*"
REMURL="ftp.lab.local"
REMDIR="TST/out bound/"
USR="vagrant"
PWD="vagrant"
# Enable email status report = 1
USEMAIL=0
EMAIL="vagrant@localhost"
MESSAGE="\n\nTransfer run date: "`date`"\n\n"
LOGFILE=~/transfer_log

SSHPASS="$PWD" sshpass -e sftp -o BatchMode=no -o ConnectTimeout=10 -o StrictHostKeyChecking=no -b - $USR@$REMURL <<EndSFTP > $LOGFILE
lcd "$LOCDIR"
cd "$REMDIR"
ls -l $REMFIL
mget $REMFIL
lls -l $REMFIL
bye
EndSFTP

ERRORCODE=$?
if [ ${ERRORCODE} -ne 0 ]; then
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR failed with error $ERRORCODE."
else
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR was successful."
fi

if [ ${USEMAIL} -eq 1 ]; then
    echo -e "$MESSAGE\n" | /usr/bin/mutt -e "my_hdr From: File Transfer <noreply@localhost.localdomain>" -s "Transfer Status Report" -a $LOGFILE -- $EMAIL
fi
