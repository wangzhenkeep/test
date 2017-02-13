#!/bin/bash
#
#
#	MIB_report.sh
#
#	This program MIB_report was a submodule of MIB.
#	It will automatically choose the most likely reference genome. 
#	
#	MIB_report.sh <annotated BLAST file> <NGS>
#
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-08-05
### Copyright (C) 2015 Yang Li - All Rights Reserved
if [ $# -lt 5 ]
then
	echo -e "$0\tUsage: <annotated BLAST file> <NGS> <Bac_16s_full> <MIB_PATH> <16s-related-reads>"
	exit
fi

blast_file=$1
NGS=$2
BAC_16S_FULL=$3
MIB_PATH=$4
BAC_16S_READS=$5
address=`pwd`

MIB_create_tmp_table.pl -f sam $blast_file
#
#format qseqid specis genus family
#
echo -e "$(date)\t$0\tdone creating $blast_file.tempsorted"
sed 's/ /_/g' $blast_file > temp.$blast_file.nospace
awk -F "\t" '{print$4}' $blast_file.tempsorted | sort -t $'\t'  -u -k1,1 > temp.$blast_file.uniq.genus
sort -t $'\t' -r -n  -k 2,2 $blast_file.genus.counttable | head -10 |awk -F "\t" '{print $1}'>$blast_file.genus.counttable.10
cat temp.$blast_file.uniq.genus | sort -t $'\t' -u -k1,1 | sed 's/ /_/g' | sed /^[[:space:]]*$/d > temp.all.$NGS.uniq.genus
echo -e "$(date)\t$0\tdone creating temp.all.$NGS.uniq.genus"
#while read genus
#for genus in `cat temp.all.$NGS.uniq.genus` 
for genus in `cat $blast_file.genus.counttable.10`
	do
		echo -e "$(date)\t$0\tParsing genus: $genus"
		echo -e "$(date)\t$0\tCreating temp file for $genus"
		mkdir temp.$genus.$NGS
		START1=$(date +%s)
		##将所有reads放到对应的genus文件下并合并
		egrep "genus--$genus" temp.$blast_file.nospace | awk '{print">"$1"\n"$10}' > ./temp.$genus.$NGS/temp.$genus.fa  
		egrep "genus--$genus" temp.$blast_file.nospace | awk '{print$3}' | sed 's/gi|//g' | sed 's/|//g' | awk '{a[$1]++}END{for (i in a) print i" "a[i]}' | sort -r -k2,2 -n > ./temp.$genus.$NGS/temp.$genus.gi_time
		awk '{print$1}' ./temp.$genus.$NGS/temp.$genus.gi_time | head -n 1 > ./temp.$genus.$NGS/temp.$genus.gilist  	
		##获得前100名gi对应的fasta格式
		echo -e "$(date)\t$0\tExtract the reference genome according to the gilist from database"
		$MIB_PATH/BLAST/blastdbcmd -db $BAC_16S_FULL -entry_batch ./temp.$genus.$NGS/temp.$genus.gilist -out ./temp.$genus.$NGS/temp.$genus.gilist.fa.blastdb.fasta
		#exit 65
		echo -e "$(date)\t$0\tReference sequence has been achieved: temp.$genus.gilist.fa.blastdb.fasta"
		cd temp.$genus.$NGS
		##将比对结果中reads进行blast，比对对象为temp.$genus.gilist.fa.blastdb.fasta
		MIB_blast_reads2gi.sh temp.$genus.fa temp.$genus.gilist.fa.blastdb.fasta $genus temp.$genus.$NGS.blastn $MIB_PATH
		##画图
		echo -e "$(date)\t$0\tPlot blast output against reference"
		#sh $address/plot_blast.sh temp.$genus.$NGS.blastn temp.$genus.gilist.fa.blastdb.fasta $genus $NGS
		MIB_plot_blast.sh temp.$genus.$NGS.blastn temp.$genus.gilist.fa.blastdb.fasta $genus $NGS $BAC_16S_READS
		cd ..
		#exit
		##
	done		

