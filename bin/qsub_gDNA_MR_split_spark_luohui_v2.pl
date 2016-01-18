#!/usr/bin/perl
use strict;
use warnings;
die "usage:*.pl <list> <Result_dir (absolute_path)> <port>\n" if(@ARGV !=3);
#print "$ARGV[1]\n";
my $binpath=`dirname $0`;
chomp $binpath;
#print "$binpath\n";
#exit;
open IN,"$ARGV[0]";
if (-e $ARGV[1]) {#system "rm -rf $ARGV[1]";system "mkdir $ARGV[1]";
}else{system "mkdir -p $ARGV[1]";}
while (<IN>) {
	if(/^$/){next;}
        chomp $_;
	my @temp=split/\s+/,$_;
        my $temp=$temp[0];my $file_name=$temp[1];
                $temp=~s/.+\/(\S+)$/$1/;
                $temp=~s/(\S+)\.\S+$/$1/;
		$temp=~s/\.fastq|\.bam//g;
        my $sh="pgs_$temp.sh";
	system "rm -rf $ARGV[1]/$temp";
        open SH,">$ARGV[1]/$sh";
        print SH "#!/bin/bash\n#\$ -S /bin/bash\n\n";
	#print SH "ssh root\@master \"mkdir -p $ARGV[1] \"\n";
	print SH "cd $ARGV[1]\n";
        print SH "perl $binpath/../High_PPI/gDNA/gDNA_pipeline_600k_qsub_spark_luohui_v2.pl $temp[0] $binpath/../Database/hg19.fasta $ARGV[1]/$temp\n";
	print SH "java -jar $binpath/batik-1.6/batik-rasterizer.jar $ARGV[1]/$temp/$temp\.*.svg\n";
	print SH "perl $binpath/log2xls.pl $ARGV[1]/$temp/$temp.log $ARGV[1]/$temp/$temp.Statistics $ARGV[1]/$temp/$temp.xls $file_name 3.5\n";
	print SH "rm $ARGV[1]/$temp/*.bam\n";
	print SH "perl $binpath/print_time.pl $ARGV[1]/$temp\n";
	#print SH "ssh root\@master \"rm -rf $ARGV[1]/$temp\"\n";
	print SH "scp -r $ARGV[1]/$temp root\@master:$ARGV[1]/\n";
	print SH "scp $ARGV[1]/pgs_$temp.* root\@master:$ARGV[1]/\n";
	print SH "rm -rf $ARGV[1]/$temp  $ARGV[1]/pgs_$temp.*";
        close SH;
        #system "qsub -e $ARGV[1]/ -o $ARGV[1] $ARGV[1]/$sh";
	#system "nohup sh $ARGV[1]/$sh 1 > $ARGV[1]/$sh.o 2> $ARGV[1]/$sh.e &";
	my @slave=("root\@slave1","root\@slave2","root\@slave3","root\@slave4","root\@slave5","root\@slave6");
=cut
	foreach my $one (@slave) {
		#system "ssh $one \"rm -rf $dir\"";
		system "ssh $one \"mkdir -p $ARGV[1]\"";
		system "ssh $one \"rm -rf $ARGV[1]/$sh\"";
		system "ssh $one \"rm -rf $ARGV[1]/$temp\"";
		system "scp $ARGV[1]/$sh $one:$ARGV[1]/";
	}
=cut
	system " nohup /usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[2]  --total-executor-cores 1  --master spark://master:7077 /share/data/wangzhen/project/2015/PGS_spark/bin/bin/exec.py $ARGV[1]/$sh $temp $ARGV[1] &> $ARGV[1]/$sh.out &";
	#system " nohup /usr/lib/spark/bin/spark-submit --total-executor-cores 1  --master spark://master:7077 /opt/data/PGS/bin/bin/exec.py $ARGV[1]/$sh > wz.test &";
}

