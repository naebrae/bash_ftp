#!/bin/bash
# Secure-FTP (sftp) transfer using curl.
# sftp is ftp over a ssh tunnel using the ssh port.

LOCDIR="/home/vagrant/inbound/"
REMFIL="*"
REMURL="sftp://ftp.lab.local:22"
REMDIR="TST/outbound/"
REMARC="TST/outbound_archive/"
# USRPWD can be user:pass or just user and curl will ask for a password
USRPWD="vagrant:vagrant"
# Enable email status report
USEMAIL=1
EMAIL="vagrant@localhost"
MESSAGE="\n\nTransfer run date: "`date`"\n\n"
LOGFILE=~/transfer_log

files=$(curl --silent --show-error --connect-timeout 10 --insecure --use-ascii --user $USRPWD --list-only $REMURL"$REMDIR" 2>$LOGFILE)
ERRORCODE=$?
if [ ${ERRORCODE} -ne 0 ]; then
    MESSAGE="Transfer of $REMURL$REMDIR to $LOCDIR failed with error $ERRORCODE."
    if [ ${USEMAIL} -eq 1 ]; then
        echo -e "$MESSAGE\n" | /usr/bin/mutt -e "my_hdr From: File Transfer <noreply@localhost.localdomain>" -s "Transfer Status Report" -a $LOGFILE -- $EMAIL
    fi
fi

# Less than or equal to 4 allows for . and .. in file list.
if [ ${#files} -le 4 ]; then
    echo "Could not find transfer files exiting ..."
    exit 1
fi

flist=""
IFS=$'\n'
cd "$LOCDIR"
count=0
for f in $files; do
  if [ "x$f" != "x." ] && [ "x$f" != "x.." ]; then
    file=$REMURL"$REMDIR$f"
    curl --silent --show-error --connect-timeout 10 --insecure --use-ascii --user $USRPWD -O $file 2>>$LOGFILE
    ERRORCODE=$?
    if [ ${ERRORCODE} -eq 0 ]; then
      count=$(( $count +1 ))
      flist=$flist"\n"$f
      archiveCMD="-RENAME '$REMDIR$f' '$REMARC$f'"
      curl --silent --show-error --connect-timeout 10 --insecure --use-ascii --user $USRPWD -Q "$archiveCMD" $REMURL >/dev/null 2>>$LOGFILE
      ERRORCODE=$?
      if [ ${ERRORCODE} -ne 0 ]; then
           MESSAGE+="Error renaming: $archiveCMD\n"
      fi
    else
      MESSAGE+="Error downloading $file\n"
    fi
  fi
done
echo "$count files"

if [ ${ERRORCODE} -ne 0 ]; then
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR failed with error $ERRORCODE."
else
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR was successful."
    MESSAGE+="\n\nFiles transferred:\n\n$flist\n\n"
fi

if [ ${USEMAIL} -eq 1 ]; then
    echo -e "$MESSAGE\n" | /usr/bin/mutt -e "my_hdr From: File Transfer <noreply@localhost.localdomain>" -s "Transfer Status Report" -a $LOGFILE -- $EMAIL
fi

