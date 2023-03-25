#!/bin/bash

STARTTIME=$(date +%s)

LOCDIR="/home/vagrant/in bound/"
REMFIL="file *"
REMURL="ftp://ftp.lab.local"
REMDIR="/~/out bound/"
USRPWD="vagrant:vagrant"

IFS=$'\n'
cd "$LOCDIR"
count=0
for f in $(curl --silent --show-error --connect-timeout 10 --user $USRPWD --insecure --ftp-ssl --list-only $REMURL"$REMDIR"); do
    file=$REMURL"$REMDIR$f"
    curl --silent --show-error --write-out "%{url_effective} (%{size_download} bytes at %{speed_download} KiB/s)\n" --connect-timeout 10 --insecure --ftp-ssl --user $USRPWD -O $file
    if [ $? -ne 0 ]; then
        echo "Error downloading $file"
    fi
    count=$(( $count +1 ))
done

ENDTIME=$(date +%s)
echo "$count files transferred in $(($ENDTIME - $STARTTIME)) seconds"

echo; echo
file=${file/ /\\ }
echo "curl --silent --show-error --write-out \"%{filename_effective},%{ftp_entry_path},%{speed_download},%{speed_upload},%{time_total},%{url_effective},%{size_download},%{size_upload}\n\" --connect-timeout 10 --insecure --ftp-ssl --user $USRPWD -O $file"
echo "curl -Lo /dev/null -skw \"\ntime_connect: %{time_connect}s\\ntime_namelookup: %{time_namelookup}s\\ntime_pretransfer: %{time_pretransfer}s\\ntime_starttransfer: %{time_starttransfer}s\ntime_redirect: %{time_redirect}s\\ntime_total: %{time_total}s\\n\\n\" --ftp-ssl --user $USRPWD -O $file"

exit 0
