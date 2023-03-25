#!/bin/bash
# Secure-FTP (sftp) transfer using curl.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/outbound/"
LOCFIL="*"
LOCARC="/home/vagrant/outbound_archive/"
REMURL="sftp://ftp.lab.local:22"
REMDIR="TST/inbound/"
# USRPWD can be user:pass or just user and curl will ask for a password
USRPWD="vagrant:vagrant"
# Enable email status report
USEMAIL=1
EMAIL="vagrant@localhost"
MESSAGE="\n\nTransfer run date: "`date`"\n\n"
LOGFILE=~/transfer_log

#
# This is a work around for curl not supporting * in the file list
# It converts *.txt to {/home/vagrant/outbound/file2.txt,/home/vagrant/outbound/file 3.txt}
#
IFS=$'\n'
files="{"
for f in $(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort); do
    [[ -e $f ]] && files+="$f,"
done
files+="}"
files=${files/,\}/\}}

# Test to make sure that the file list is not the empty list {}
#
if [ ${#files} -gt 2 ]; then
    curl --silent --show-error --connect-timeout 10 --insecure --use-ascii --user $USRPWD -T "${files}" $REMURL$REMDIR 2>$LOGFILE
    ERRORCODE=$?
else
    echo "Could not find transfer files! Exiting ..."
    exit 1
fi 

if [ ${ERRORCODE} -ne 0 ]; then
    MESSAGE+="Transfer of $LOCDIR to $REMURL$REMDIR failed with error $ERRORCODE."
else
    MESSAGE+="Transfer of $LOCDIR to $REMURL$REMDIR was successful."
    if [ "x$LOCARC" != "x" ] && [ -d $LOCARC ]; then
        mv -f "$LOCDIR"$LOCFIL "$LOCARC"
    else
        MESSAGE+="\nCould not archive files to $LOCARC\n"
    fi
    MESSAGE+="\n\nFiles transferred:\n\n$files\n\n"
fi

if [ ${USEMAIL} -eq 1 ]; then
    echo -e "$MESSAGE\n" | /usr/bin/mutt -e "my_hdr From: File Transfer <noreply@localhost.localdomain>" -s "Transfer Status Report" -a $LOGFILE -- $EMAIL
fi
