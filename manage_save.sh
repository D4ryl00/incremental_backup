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
	echo -n `expr "$f" : "${1}_\(.*\)"`
    done
}

cd $DEST_PATH

# source folder must exist
if [ -d ${OFFSET}_* ]; then
    if [ "0_`date +%Y%m%d`" != 0_* ]; then
	YOUNG_ORIGIN_FOLDER="`find $(pwd) -maxdepth 1 -mtime -${I_TIME} -type d -name "${OFFSET}_*"`"
	ORIGIN_FOLDER="${OFFSET}_*"
	NEW_FOLDER="${OFFSET}_`date +%Y%m%d`"
	# test if the interval time is respected to make the backup (because empty)
	if [ ! -d "$YOUNG_ORIGIN_FOLDER" ]; then
	    # delete the oldest backup
	    FOLDER="${INDEX}_*"
	    if [ -d "$FOLDER" ]; then
      		rm -rf "$FOLDER"
	    fi
	    # shift the order of each backup
	    for i in `seq $INDEX -1 $(expr $OFFSET + 1)`;
	    do
		j=`expr $i - 1`
		FOLDER="${j}_*"
		if [ -d "$FOLDER" ]; then
		    mv "$FOLDER" "./${i}_`extract_date ${j}`"
		fi
	    done
	    echo -n '1,'
	else #the interval time is not respected
	    echo -n '0,'
	fi
    else # one backup make today, just overwrite it
	echo -n '1,'
    fi
else # no backup yet
    echo -n '1,'
fi

# return ...
HARD_LINKS_SOURCE="`expr $OFFSET + 1`_*"
if [ -d $HARD_LINKS_SOURCE ]; then
    echo "$HARD_LINKS_SOURCE"
fi

