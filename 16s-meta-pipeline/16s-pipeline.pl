#!/usr/bin/perl

=head1 Description

=head1 
	Author: wanghaiyin,  wanghaiyin@celloud.cn
	Version: 1.1,  Date: 2015-10-13

=head1 Usage

	print "perl $0 <fq1>  <fq2> <outdir> \n";

=head1 Example

=cut
#
#use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/lib";
use File::Basename qw(basename dirname); 

if (@ARGV!=3) {die"Usage *.pl <fq1>  <fq2>  <outdir> \n";exit;}
#open out,">>run.sh";
my @fq;
$fq[0]=$ARGV[0];
$fq[1]=$ARGV[1];
my $outdir=$ARGV[2];
#my $LOG;
# get index list

if (-d "$outdir/QC") {
	system "rm -rf $outdir/QC";
}

if (-d "$outdir/result") {
	system "rm -rf $outdir/result";

}

mkdir ($outdir) unless (-d $outdir);
mkdir ("$outdir/QC") unless(-d "$outdir/QC");
mkdir ("$outdir/result") unless(-d "$outdir/result");




#====================================================================================================================
#  +------------------+
#  |   runprogram     |
#  +------------------+
#$CPU ||= $RUN eq 'qsub' ? 100 : 3;
my $Time_Start = sub_format_datetime(localtime(time())); 
my $Data_Vision = substr($Time_Start,0,10);
open (LOG, ">$outdir/LOG.txt") ||  die "Can't write LOG: $!\n";

#====================================================================================================================
#  +------------------+
#  |   runprogram     |
#  +------------------+
my $Time_Start1 = sub_format_datetime(localtime(time()));
print LOG "[$Time_Start1]\tUncompress start!\n";
#######´¦Àíreads
chdir "$outdir";
my $mark=0;
my($fq1_new,$fq2_new,$filename1,$filename2);
if ($fq[0]=~/\.tar.gz$/) {
	$mark=1;
	system "tar -zxvf $fq[0] -C ./";
	$fq1_new=basename $fq[0];
	$fq1_new=~s/\.tar\.gz//;
}elsif ($fq[0]=~/\.gz$/) {
	$mark=1;
	$fq1_new= basename $fq[0];
	$fq1_new=~s/\.gz//;
	system "gunzip -c $fq[0] >$fq1_new";
}
if ($fq[1]=~/\.tar.gz$/) {
	$mark=1;
	system "tar -zxvf $fq[1] -C ./";
	$fq2_new=basename $fq[1];
	$fq2_new=~s/\.tar\.gz//;
}elsif ($fq[1]=~/\.gz$/) {
	$mark=1;
	$fq2_new=basename $fq[1];
	$fq2_new=~s/\.gz//;
	system "gunzip -c $fq[1] >$fq2_new";
}

if ($mark==0) {
	$filename1=basename $fq[0];
	$filename2=basename $fq[1];
	system "cp $fq[0] .";
	system "cp $fq[1] .";
	$fq[0]=$filename1;
	$fq[1]=$filename2;
#	$filename1="trimed/".$filename1;
#	$filename2="trimed/".$filename2;
}else{
	$filename1=$fq1_new;
	$filename2=$fq2_new;
	$fq[0]=$filename1;
	$fq[1]=$filename2;
}
#runcmd ("shell", " #!/bin/sh\n");

print "$fq[0] $fq[1]\n";
runcmd ("fastQC", " $Bin/FastQC/fastqc $fq[0] $fq[1] -o QC");
runcmd ("statistic", "perl $Bin/statistic.pl QC");
#'/bin/cat  $fq[0] $fq[1] >all.fastq';
runcmd ("cat", "cat  $fq[0] $fq[1] >all.fastq");
#runcmd ("MIB prepare", " /share/data/liyang/MIB/MIB.sh -z -i all.fastq");
#runcmd ("MIB", "env LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/share/biosoft/glibc-2.14/lib LC_ALL=C  /share/data/liyang/MIB/MIB.sh  -c all.fastq.conf -i all.fastq");
runcmd ("MIB prepare", "/share/data/liyang/MIB_SNAP_0.1.1/MIB.sh -z -i all.fastq -r /share/data/liyang/MIB_SNAP_0.1.1");
runcmd ("MIB", "env LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/share/biosoft/glibc-2.14/lib LC_ALL=C /share/data/liyang/MIB_SNAP_0.1.1/MIB.sh  -c all.fastq.conf -i all.fastq");

#runcmd ("MIB prepare", " /share/biosoft/perl/wangzhen/16s-meta-pipeline/MIB/MIB.sh -z -i all.fastq");
#runcmd ("MIB", "env LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/share/biosoft/glibc-2.14/lib LC_ALL=C  /share/biosoft/perl/wangzhen/16s-meta-pipeline/MIB/MIB.sh  -c all.fastq.conf -i all.fastq");
#runcmd ("MIB prepare", " MIB.sh -z -i all.fastq");
#runcmd ("MIB", " MIB.sh  -c all.fastq.conf -i all.fastq");
runcmd ("mv", "mv family_distribution.all.fastq.png result ");
runcmd ("mv", "mv genus_distribution.all.fastq.png result ");
runcmd ("mv", "mv reads_distribution.all.fastq.png result ");
runcmd ("mv", "mv all.fastq.report/coverage_map_top10/ result ");
runcmd ("mv", "mv all.fastq.report/taxi.all.fastq.table  result ");
runcmd ("cp", "cp all.fastq.genus.top15  result/all.fastq.genus.top10 ");
runcmd ("cp", "cp all.fastq.reads_distribution  result ");
runcmd ("get conclusion", "perl $Bin/get-conclusion.pl result/taxi.all.fastq.table result/conclusion.txt ");
runcmd ("family percent", "perl $Bin/percent_sum.pl  all.fastq.nohost.fastq.sam.addseq.all.annotated.family.counttable  result/family.distribution.lis");
runcmd ("reads percent", "perl $Bin/percent_reads.pl   all.fastq.reads_distribution result/all.fastq.reads_distribution");

my $Time_End= sub_format_datetime(localtime(time()));
#print LOG "Running from [$Time_Start] to [$Time_End]\n";
print " finished. Running from [$Time_Start] to [$Time_End]\n";


#====================================================================================================================
#  +------------------+
#  |   subprogram     |
#  +------------------+
sub sub_format_datetime{
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $day, $hour, $min, $sec);
}

sub WriteFq{
	my ($fh,$name,$seq,$qual) = @_;
	print $fh "\@$name\n$seq\n\+\n$qual\n";
}

sub runcmd{
	my ($program,$cmd)=@_;
	open (SH, ">>work.sh") ||  die "Can't write work: $!\n";
	print SH "$cmd \n";
	LOGFILE(0,$program);
	system($cmd) && LOGFILE(1,$program); 
	LOGFILE(2,$program); 
	close SH;
}

sub writecmd{
	my $cmd = shift;
	open (SH, ">>work.sh") ||  die "Can't write work: $!\n";
	print SH "$cmd";
	close SH;
}
sub LOGFILE{
	my $flog=shift;
	my $program=shift;
	my $Time= sub_format_datetime(localtime(time()));
	#print LOG "[$Time +0800]\ttask\t0\tstart\t$program\tStart to analysis......\n";
	if($flog==0){
		print LOG "[$Time +0800]\ttask\t0\tstart\t$program\tDone.\n";
	}elsif ($flog==2) {
		print LOG "[$Time +0800]\ttask\t0\tend\t$program\tDone.\n";
	}else{
		print LOG "[$Time +0800]\ttask\t0\terror\t$program\tAt least one $program in this section is in error.\n";
		close LOG;
		exit;
	}
}
close LOG;
