#!/bin/bash

watch_dir=/opt/foodforcuckoo
analyzed_bins=/opt/cuckoo/storage/analyzed_bins/
cuckoo_dir=/opt/cuckoo/utils

# simple example of how to do some interim processing
if [[ -f $1 ]]; then
        if 7z l $1 | egrep -q "^Type = (7z|zip)"; then
                ending=`echo ${1%%.*} | awk '{print substr($0,length,1)}'`
                passwords=("infected")
                for pass in "${passwords[@]}"; do
                        #7z will extract non-pw protected archives if a password is supplied
                        7z e -y -o$watch_dir -p$pass $1
                        if [[ $? -eq 0 ]]; then
                                break
                        fi
                        rm $1 &>/dev/null
                done
        #implement other tasks such as pffexport here
        else
                # check to see if the file has any size and if it doesn't just delete it
                file $1 | grep -v "DLL" | grep -v "data" > /dev/null 2>&1
                if [[ -s $1 && $? -eq 0 ]]
                then
                        md5=$(basename $1 2>&1)
                        mv $1 $analyzed_bins
                        cd $cuckoo_dir && python submit.py $analyzed_bins$md5
                        echo $analyzed_bins$md5
                fi
                rm $1 &>/dev/null
        fi
fi