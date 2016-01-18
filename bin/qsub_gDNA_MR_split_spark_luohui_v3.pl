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
}else{system "mkdir $ARGV[1]";}
while (<IN>) {
	if(/^$/){next;}
        chomp $_;
	my @temp=split/\s+/,$_;
        my $temp=$temp[0];my $file_name=$temp[1];
                $temp=~s/.+\/(\S+)$/$1/;
                $temp=~s/(\S+)\.\S+$/$1/;
		$temp=~s/\.fastq|\.bam//g;
        my $sh="pgs_$temp.sh";
        open SH,">$ARGV[1]/$sh";
        print SH "#!/bin/bash\n#\$ -S /bin/bash\n\n";
	print SH "cd $ARGV[1]\n";
        print SH "perl $binpath/../High_PPI/gDNA/gDNA_pipeline_600k_qsub_spark_luohui_v3.pl $temp[0] $binpath/../Database/hg19.fasta $ARGV[1]/$temp\n";
	print SH "java -jar $binpath/batik-1.6/batik-rasterizer.jar $ARGV[1]/$temp/$temp\.*.svg\n";
	print SH "perl $binpath/log2xls.pl $ARGV[1]/$temp/$temp.log $ARGV[1]/$temp/$temp.Statistics $ARGV[1]/$temp/$temp.xls $file_name 3.5\n";
	#print SH "rm $ARGV[1]/$temp/*.bam\n";
	print SH "perl $binpath/print_time.pl $ARGV[1]/$temp\n";
        close SH;
        #system "qsub -e $ARGV[1]/ -o $ARGV[1] $ARGV[1]/$sh";
	#system "sh $ARGV[1]/$sh";
	system " nohup /usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[2] --total-executor-cores 1  --master spark://master:7077 /opt/data/PGS/bin/bin/exec_v3.py $ARGV[1]/$sh > wz.test &";
}

