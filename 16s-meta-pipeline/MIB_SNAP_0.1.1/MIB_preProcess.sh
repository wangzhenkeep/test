#!/bin/bash
#
#
#	This is the script for preprocessing.
#
#	Quick guide:
#	./preprocess.sh <inputfile> <length_cutoff> <left_cutoff> <right_cutoff> <quality_cutoff>
#
#
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-10-13
### Copyright (C) 2015 Yang Li All Rights Reserved


if [ $# -lt 5 ]
then
	echo "usage: $0 <inputfile> <length_cutoff> <left_cutoff> <right_cutoff> <quality_cutoff>"
	echo -e ""
	exit 65
fi
########
INPUT=$1
length_cutoff=$2
left_cutoff=$3
right_cutoff=$4
quality_cutoff=$5
########
echo "$0\tBegin to quality control"
total_num=$(wc -l $INPUT | awk '{print $1}')
let "num=$total_num/4"
echo -e "The number of reads are $num"
echo -e "$0\tBegin to Quality Control"
num_total_reads=`prinseq-lite.pl -stats_info -fastq $INPUT | grep "reads" | awk '{print$3}'`
echo "seqtk trimfq -b $left_cutoff -e $right_cutoff $INPUT > $INPUT.end"
seqtk trimfq -b $left_cutoff -e $right_cutoff $INPUT > $INPUT.end
prinseq-lite.pl -derep 14 -min_len "$length_cutoff" -min_qual_mean "$quality_cutoff" noniupac -lc_method dust -lc_threshold 7 -fastq $INPUT.end -out_good $INPUT.preprocessed

chmod 777 *.*
num_preprocessed_reads=`prinseq-lite.pl -stats_info -fastq $INPUT.preprocessed.fastq | grep "reads" | awk '{print$3}'`
low_quality_reads=$(( $num_total_reads - $num_preprocessed_reads))
#sudo sh -c 'echo -e "Total_sequences\t$num_total_reads" > $inputfile.reads_distribution'
echo -e "Total_sequences\t$num_total_reads" > $INPUT.reads_distribution
echo -e "Low_quality_reads\t$low_quality_reads" >> $INPUT.reads_distribution

