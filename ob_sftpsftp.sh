#!/bin/bash
# Secure-FTP (sftp) transfer using sftp.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/out bound/"
LOCFIL="file\ *.txt"
REMURL="ftp.lab.home"
REMDIR="TST/in bound/"
USR="vagrant"
PWD="vagrant"
# Enable email status report = 1
USEMAIL=0
EMAIL="vagrant@localhost"
MESSAGE="\n\nTransfer run date: "`date`"\n\n"
LOGFILE=~/transfer_log

files=$(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort)
if [ ${#files} -eq 0 ]; then
    echo "Could not find transfer files exiting ..."
    exit 1
fi

SSHPASS="$PWD" sshpass -e sftp -o BatchMode=no -o ConnectTimeout=10 -o StrictHostKeyChecking=no -b - $USR@$REMURL <<EndSFTP > $LOGFILE
lcd "$LOCDIR"
cd "$REMDIR"
lls -l $LOCFIL
mput $LOCFIL
ls -l $LOCFIL
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
