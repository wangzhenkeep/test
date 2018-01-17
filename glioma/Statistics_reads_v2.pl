#!/usr/bin/perl -w

#*****************************************************************************
# FileName: count_nonfusion.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-9-15
# Description: This code is to count the sum of reads not containning fusion.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <sam> <tab> <out>
USAGE
if (@ARGV!=3) {
	die $usage;
}
my $sam=shift;
my $tab=shift;
my $out=shift;
my (%p1,%q19,%control);

open (T,$tab) or die $!;
#gene    chr     start   end
my $head =<T>;
chomp $head;
while (<T>) {
#13      chr19   3226063 3226208
#TP73    chr1    3599588 3599748
	chomp;
	if (/^\s+$/) {
		next;
	}
	my ($id,$chr,$start,$end)=(split /\t/,$_);
	$id="$chr\_$start\_$end\_$id";
	if ($chr eq "chr1") {
		$p1{$id}=$_;
	}elsif ($chr eq "chr19") {
		$q19{$id}=$_;
	}else {
		$control{$id}=1;
	}
}
close T;

open SAM, $sam or die "Can't open '$sam': $!\n";
my (%hash,$all,@arr);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^\@/ | $line=~/^\s+$/) {
		if ($line=~/^\@SQ/) {
			my $sq_info=(split/\s+/,$line)[1];
			my $sq_name=(split/:/,$sq_info)[1];
			push @arr,$sq_name;
		}
		next;
	}
	#MN00129:11:000H23NKW:1:11102:19803:15901;1:N:0:10       0       chr17_41234373_41234605_BRCA1_exon11    101     0       128M18I5M       *       0       0       GTCACTTATGATGGAAGGGTAGCTGTTAGAAGGCTGGCTCCCATGCTGTTCTAACACAGCTTCTAGTTCAGCCATTTCCTGCTGGAGCTTTATCAGGTTATGTTGCATGGTATCCCTCTGCTTCAAAAACGATAAATGGCACCAAGAAAAT IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII AS:i:-71        XN:i:0  XM:i:2  XO:i:1  XG:i:18 NM:i:20 MD:Z:129C0G2    YT:Z:UU
	#MN00129:11:000H23NKW:1:11102:17039:17882;1:N:0:10       0       chr17_41234373_41234605_BRCA1_exon11    101     42      71M     *       0       0       GTCACTTATGATGGAAGGGTAGCTGTTAGAAGGCTGGCTCCCATGCTGTTCTAACACAGCTTCTAGTTCAG IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:71 YT:Z:UU
	my ($chr,$start,$rmap,$Tlen)=(split /\t/ , $line)[2,3,5,8];
	#if ($rmap!~/M/) {
	if ($Tlen==0) {
		next;
	}
	$hash{$chr}++;
	$all++;
}
close SAM;

my (@p,@q,@c);
foreach my $key (keys %p1) {
	if (exists $hash{$key}) {
		push @p,$hash{$key};
	}else{
		push @p,0;
	}
}

foreach my $key (keys %q19) {
	if (exists $hash{$key}) {
		push @q,$hash{$key};
	}else{
		push @q,0;
	}
}

foreach my $key (keys %control) {
	if (exists $hash{$key}) {
		push @c,$hash{$key};
	}else{
		push @c,0;
	}
}
my (@pvalue,@qvalue,@cvalue);
foreach $p (@p) {
	my $pvalue=$p*10000/$all;
	push @pvalue,$pvalue; 
	@pvalue = sort {$b <=> $a} @pvalue;
}	
	my $pmedian=$pvalue[4];
	$pmedian=sprintf "%.3f",$pmedian;

foreach $q (@q) {
	my $qvalue=$q*10000/$all;
	push @qvalue,$qvalue;
	@qvalue = sort {$b <=> $a} @qvalue;
}
	my $qmedian=($qvalue[2]+$qvalue[3])/2;
	$qmedian=sprintf "%.3f",$qmedian;

foreach $c (@c) {
	my $cvalue=$c*10000/$all;
	push @cvalue,$cvalue;
	@cvalue = sort {$b <=> $a} @cvalue;
}
	my $cmedian=$cvalue[2];
	$cmedian=sprintf "%.3f",$cmedian;

my ($p1result,$q19result);
$p1result = $pmedian/$cmedian;
$p1result=sprintf "%.3f",$p1result;
$q19result = $qmedian/$cmedian;
$q19result=sprintf "%.3f",$q19result;
open OUT,">",$out or die "Can't open '$out': $!\n";
	if ($p1result < 0.65 && $q19result < 0.65) {
		print OUT "cut_off_value\t0.65\n1p\t+\n19q\t+\n";
	}elsif ($p1result < 0.65 && $q19result > 0.65) {
		print OUT "cut_off_value\t0.65\n1p\t+\n19q\t-\n";
	}elsif ($p1result > 0.65 && $q19result > 0.65) {
		print OUT "cut_off_value\t0.65\n1p\t-\n19q\t-\n";
	}else {
		print OUT "cut_off_value\t0.65\n1p\t-\n19q\t+\n";
	}

#print OUT "1p_median\t$pmedian\n19q_median\t$qmedian\ncontrol_median\t$cmedian\n1p_result\t$p1result\n19q_result\t$q19result\n";

#foreach my $i (@arr) {
#	if (exists $hash{$i}) {
#		print OUT "$i\t$hash{$i}\n";
#	}else {
#}
#}
close OUT;
