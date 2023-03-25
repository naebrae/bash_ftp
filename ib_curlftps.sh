#!/bin/bash
# FTP-Secure (ftps) transfer using curl.
# Explicit ftps connects to standard ftp port (default 21) and explicity requests a secured connection.
# Implicit ftps connects to the secure ftp port (default: 990) and ssl is implied by the connection.

LOCDIR="/home/vagrant/inbound/"
#Explicit
REMURL="ftp://ftp.lab.local:21"
#Implicit 
#REMURL="ftps://ftp.lab.local:990"
REMDIR="/TST/outbound/"
REMFIL="*"
REMARC="/TST/outbound_archive/"
# USRPWD can be user:pass or just user and curl will ask for a password
USRPWD="vagrant:vagrant"
# Enable email status report
USEMAIL=1
EMAIL="vagrant@localhost"
MESSAGE="\n\nTransfer run date: "`date`"\n\n"
LOGFILE=~/transfer_log

files=$(curl --silent --show-error --connect-timeout 10 --insecure --ftp-ssl --use-ascii --user $USRPWD --list-only $REMURL"$REMDIR" 2>$LOGFILE)
ERRORCODE=$?
if [ ${ERRORCODE} -ne 0 ]; then
    echo "Transfer of $REMURL$REMDIR to $LOCDIR failed with error $ERRORCODE"
    exit 1
fi

# Less than or equal to 4 allows for . and .. in file list.
if [ ${#files} -le 4 ]; then
    echo "Could not find transfer files exiting ..."
    exit 1
fi

# This retrieves the remote ftp_entry_path to be prepended to the remote directory path for the remote rename to work
REMBASE=$(curl --silent --show-error --connect-timeout 10 --insecure --ftp-ssl --use-ascii --user $USRPWD -w "%{ftp_entry_path}\n" -o /dev/null $REMURL)
ERRORCODE=$?
if [ ${ERRORCODE} -ne 0 ]; then
    echo "Determine remote ftp_entry_path failed with error $ERRORCODE"
fi

ERRORCODE=0
flist=""
IFS=$'\n'
cd "$LOCDIR"
for f in $files; do
    file=$REMURL"$REMDIR$f"
    curl --silent --show-error --connect-timeout 10 --insecure --ftp-ssl --use-ascii --user $USRPWD -O $file 2>>$LOGFILE
    ERRORCODE=$?
    if [ ${ERRORCODE} -eq 0 ]; then
      # This creates a local 0 byte file if the curl transfer was successful but no local file created (curl bug with 0 byte files)
      if [ ! -f $f ]; then touch $f; fi

      flist=$flist"\n"$f
      curl --silent --show-error --connect-timeout 10 --insecure --ftp-ssl --use-ascii --user $USRPWD -Q "-RNFR $REMBASE$REMDIR$f" -Q "-RNTO $REMBASE$REMARC$f" -o /dev/null $REMURL 2>>$LOGFILE
      RENAMECODE=$?
      if [ ${RENAMECODE} -ne 0 ]; then
          MESSAGE+="Error renaming $file\n"
      fi
    else
      MESSAGE+="Error downloading $file\n"
    fi
done

if [ ${ERRORCODE} -ne 0 ]; then
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR failed with error $ERRORCODE"
else
    MESSAGE+="Transfer of $REMURL$REMDIR to $LOCDIR was successful."
    MESSAGE+="\n\nFiles transferred:\n\n$flist\n\n"
fi

if [ ${USEMAIL} -eq 1 ]; then
    echo -e "$MESSAGE\n" | /usr/bin/mutt -e "my_hdr From: File Transfer <noreply@localhost.localdomain>" -s "Transfer Status Report" -a $LOGFILE -- $EMAIL

    # Instead of using mutt, use Curl to send email.
    # MESSAGE="From: File Transfer <noreply@localhost.localdomain>\nSubject: Transfer Status Report\n\n$MESSAGE\n.\n"
    # echo -e "$MESSAGE\n" | curl --silent --show-error --connect-timeout 10 --insecure --ssl --mail-from "File Transfer <noreply@localhost.localdomain>" --mail-rcpt $EMAIL -T - smtp://localhost:25
fi
