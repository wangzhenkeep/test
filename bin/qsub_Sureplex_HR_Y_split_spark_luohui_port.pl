#!/usr/bin/perl
use strict;
use warnings;
die "usage:*.pl <list> <Result_dir (absolute_path)>\n" if(@ARGV !=2);
my $result_path=$ARGV[1];
my $linshi_path=$ARGV[1];
$linshi_path=~s/^\/share\/data/\/share\/data_celloud/;
my $binpath=`dirname $0`;
chomp $binpath;
unless (-e $ARGV[1]) {
	system "mkdir -p $ARGV[1]";
}
open IN,"$ARGV[0]";
while (<IN>) {
	#/share/data/wangzhen/project/2015/PGS_spark/data/1.bam     1    4040
	if(/^$/){next;}
	chomp $_;
	my @temp=split/\s+/,$_;
	my $temp=$temp[0];
	my $file_name=$temp[1];
	$temp=~s/.+\/(\S+)$/$1/;
	$temp=~s/(\S+)\.\S+$/$1/;
	$temp=~s/\.fastq|\.bam//g;
	system "mkdir -p $linshi_path";
	my $sh="pgs_$temp.sh";
	open SH,">$linshi_path/$sh";
	print SH "#!/bin/bash\n#\$ -S /bin/bash\n\n";
	print SH "cd $linshi_path\n";
	print SH "perl $binpath/../High_PPI/Sureplex/Sureplex_pipeline_600k_Y_HR_split_spark_luohui_port.pl $temp[0] $binpath/../DataBase/hg19.fasta $linshi_path/$temp $temp[2]\n";
	print SH "java -jar $binpath/batik-1.6/batik-rasterizer.jar $linshi_path/$temp/$temp\.*.svg\n";
	print SH "perl $binpath/log2xls.pl $linshi_path/$temp/$temp.log $linshi_path/$temp/$temp.Statistics $linshi_path/$temp/$temp.xls $file_name\n";
	print SH "rm $linshi_path/$temp/*.bam\n";
	print SH "mkdir $result_path/$temp\n";
	print SH "cp -r $linshi_path/$temp $result_path/\n";
	print SH "cp -r $linshi_path/$sh* $result_path/\n";
	print SH "rm -r $linshi_path/$temp\n";
	print SH "perl $binpath/print_time.pl $ARGV[1]/$temp\n";
	close SH;
	system "nohup sh $linshi_path/$sh &> $linshi_path/$sh.log &";
}
close IN;
