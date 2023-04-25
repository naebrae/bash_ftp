#!/bin/bash

STARTTIME=$(date +%s)

LOCDIR="/home/vagrant/out bound/"
LOCFIL="*"
REMURL="ftp://ftp.lab.home"
REMDIR="/in bound/"
# USRPWD can be user:pass or just user and curl will ask for a password
USRPWD="vagrant:vagrant"

if [ ! -d "$LOCDIR/zero" ]
then
    mkdir "$LOCDIR/zero"
fi

IFS=$'\n'
count=0
for file in $(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort); do
    if [ ! -s "$file" ]; then
        /bin/mv -f "$file" "$LOCDIR/zero/"
        count=$(( $count +1 ))
    fi
done
echo "$count zero byte files"

files=$(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort)
if [ ${#files} -eq 0 ]; then
    echo "Could not find transfer files exiting ..."
    exit 1
fi

count=0
files="{"
for f in $(find "$LOCDIR" -maxdepth 1 -type f -name "$LOCFIL" | sort); do
    [[ -e $f ]] && f=${f/,/\\,} && files+="$f," && count=$(( $count +1 ))
done
files+="}"
files=${files/,\}/\}}
echo "$count files to transfer"

# Test to make sure that the file list is not the empty list {}
if [ ${#files} -gt 2 ]; then
    curl --silent --show-error --write-out "%{url_effective} (%{size_upload} bytes at %{speed_upload} KiB/s)\n" --connect-timeout 10 --insecure --ftp-ssl --use-ascii --user $USRPWD -T ${files} "$REMURL$REMDIR"
    ERRORCODE=$?
else
    ERRORCODE=-1
fi 

ENDTIME=$(date +%s)
echo "$count files transferred in $(($ENDTIME - $STARTTIME)) seconds"

exit 0
