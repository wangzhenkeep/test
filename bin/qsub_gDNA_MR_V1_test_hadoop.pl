#!/usr/bin/perl
use strict;
use warnings;
die "usage:*.pl <list> <Result_dir (absolute_path)>\n" if(@ARGV !=2);
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
        my $sh="pgs_$file_name.sh";
        open SH,">$ARGV[1]/$sh";
        print SH "#!/bin/bash\n#\$ -S /bin/bash\n\n";
	print SH "cd $ARGV[1]\n";
#        print SH "perl $binpath/../High_PPI/gDNA/gDNA_pipeline_600k_sortV1.pl $temp[0] $binpath/../Database/hg19.fasta $file_name\n";
	print SH "perl $binpath/../High_PPI/gDNA/gDNA_pipeline_600k_sortV1_SSH.pl $temp[0] /home/yangk/bin/Database/hg19.fasta $file_name\n";
	print SH "java -jar $binpath/batik-1.6/batik-rasterizer.jar $ARGV[1]/$file_name/$temp\.*.svg\n";
	print SH "perl $binpath/log2xls.pl $ARGV[1]/$file_name/$temp.log $ARGV[1]/$file_name/$temp.Statistics $ARGV[1]/$file_name/$temp.xls $file_name 3.5\n";
	print SH "rm $ARGV[1]/$file_name/*.bam\n";
	print SH "perl $binpath/print_time.pl $ARGV[1]/$file_name\n";
        close SH;
        system "qsub -e $ARGV[1]/ -o $ARGV[1] $ARGV[1]/$sh";
}

