#!/bin/bash
if [ $# -lt 2 ]; then
		echo "***give parameter***"
        exit;
fi
path=`dirname $0`
while true
do
  line1=`ls $2/*.result| wc -l`
  line2=`ls $2/*.txt | wc -l`
  if (($line1==24 && $line2==24))
  then
  #sh $path/append.sh $1 $2
   for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y
     do
     cat $2/chr$i.chr.result >> $1
   done
   rmdirname=`dirname $2`
   for slave in slave1 slave2 slave3
     do
     ssh $slave "rm -rf $rmdirname"
   done
   exit 1
  else 
   sleep 1
  fi
done
