#!/bin/sh
# Simulate a normal running

DIR="$(dirname "$0")"
cd $DIR

. ./ib-test.cfg

i=0
while [ $i -lt $NUMBER_BACKUP ]; do
    sh -x ../ib -c ib-test.cfg
    for j in `seq 0 1 $i`; do
	DATE=`echo ${DEST_PATH}/${j}_* | sed -e "s/^.*${j}_//g"`
	P_DATE=`date "+%Y%m%d" -d "$DATE -$TIME_BACKUP day"`
	mv ${DEST_PATH}/${j}_* ${DEST_PATH}/${j}_$P_DATE
	touch -m -d $P_DATE ${DEST_PATH}/${j}_*
    done
    i=`expr $i + 1`
done
