#!/bin/sh
# Author: Rémi BARBERO
# Date: 2017-04-14
# Mail: rems14@remibarbero.fr
# Incremental backup with hard links and time shift

### Arguments ###
# data destination folder
DEST_PATH=$1
# start number
OFFSET=$2
# number of backup
N=$3
# time interval between two backup (x * 24 hours)
I_TIME=$4
INDEX=`expr $OFFSET + $N`

# $1 is the index in the directory name (here "4": 4_YYmmdd)
extract_date () {
    # echo -n to delete newline
    for f in *_*; do
	echo -n `expr "$f" : ".*${1}_\(.*\)"`
    done
}

cd $DEST_PATH

# test if there is not backup yet, create the first folder
if [ ! -n "$(find $(pwd) -maxdepth 1 -type d -name "0_*")" ]; then
    mkdir "0_`date +%Y%m%d`"
fi

YOUNG_ORIGIN_FOLDER="`find $(pwd) -maxdepth 1 -mtime -$I_TIME -type d -name "${OFFSET}_*"`"
ORIGIN_FOLDER="`find $(pwd) -maxdepth 1 -type d -name "${OFFSET}_*"`"
NEW_FOLDER="${OFFSET}_`date +%Y%m%d`"
echo 'out of origin test'
echo $YOUNG_ORIGIN_FOLDER
if [ -n "$ORIGIN_FOLDER" ]; then
    echo 'in origin_folder test'
    # test if the interval time is respected to make the backup (because empty)
    if [ -z "$YOUNG_ORIGIN_FOLDER" ]; then
	echo 'in young test'
	# delete the oldest backup
	FOLDER="`find $(pwd) -maxdepth 1 -type d -name "${INDEX}_*"`"
	if [ -n "$FOLDER" ]; then
	    rm -rf "$FOLDER"
	fi
	echo "index: $INDEX min: `expr $OFFSET + 2` seq: `seq $INDEX -1 $(expr $OFFSET + 2)`"
	# shift the order of each backup
	for i in `seq $INDEX -1 $(expr $OFFSET + 2)`;
	do
	    j=`expr $i - 1`
	    echo "i: $i j: $j"
	    FOLDER="`find $(pwd) -maxdepth 1 -type d -name "${j}_*"`"
	    if [ -n "$FOLDER" ]; then
		mv "$FOLDER" "./${i}_`extract_date ${j}`"
		echo 'mv ok'
	    fi
	done
	# copy with hard links the newest backup to keep it before rsync it
	cp -al "$ORIGIN_FOLDER" "$(expr $OFFSET + 1)_`extract_date $OFFSET`"
    fi

    # rename the DEST_FOLDER with the current date if OFFSET = 0
    # for the firt backup only
    if [ \( $OFFSET -eq 0 \) -a \( "$(pwd)/$NEW_FOLDER" != "$ORIGIN_FOLDER" \) ]; then
	mv "$ORIGIN_FOLDER" "./$NEW_FOLDER"
    fi
fi
