##
##description:$1 database;$2 1,2,3,4,...X,Y;$3 result_file;$4 windows;$5 result_file_name
##
if [ $# -lt 5 ]; then
	echo "***give parameter***"
        exit;
fi
binpath1=`dirname $0`

if [ ! -d $3 ] ;then
	#echo "test**" > /share/data/webapps/Tools/upload/23/wz/test
	mkdir -p $3
fi
scp root@master:$3/chr$2.chr $3/chr$2.chr
perl $binpath1/sort.bam_to_200k_reads_follow_bins.average.pl $1.chr$2 $3/chr$2.chr $3/chr$2.chr.result $4  1450 &> $3/$5_log$2.txt
scp $3/chr$2.chr.result root@master:$3 &>> $3/$5_log$2.txt
scp $3/$5_log$2.txt root@master:$3
