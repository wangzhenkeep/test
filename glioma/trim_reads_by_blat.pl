#!/usr/bin/perl

#********************************************************************************
# FileName: trim_reads_by_blat.pl
# Creator: wanghaiyin, wanghaiyin2008@gmail.com
# Create Time: 2015-04-09
# Description: This code is to trim adaptor based on blat.out.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0
# ModifyList:
#    Revision: V2.0
#    Modifier: Zhanshehuan
#    ModifyTime: 2018-01-09
#    ModifyReason: Change the reads format of output and input(from fa to fq)
##********************************************************************************

=head1 Usage

        Usage: $0 [options]
                -b     blat out m8 format of gene2ref
                -s     sequence
                -o     output

=head1 Exmple


=cut
use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use lib "$Bin/../pm";
use openfile;
my ($blast,$output,$seq);
my ($Verbose,$Help);
GetOptions(
	"b:s"=>\$blast,
	"s:s"=>\$seq,
	"o:s"=>\$output,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
if ((!defined $blast or !defined $output or !defined $seq) || $Help) {
	die `pod2text $0`;
}

my (%min,%max);
open I,"$blast" or die $!;
<I>;
<I>;
<I>;
<I>;
<I>;
while (my $line=<I>) {
	#33      1       0       0       0       0       0       0       +       NCCL-000aef73-1db5-455a-ba45-38a1d812d541/1     100     0       34      PrefixPE/1      34      0       34      1       34,     0,      0,
	chomp $line;
	my @a=split(/\t/,$line);
	if ($line=~/Query_name/) {
		next;
	}
	if (!exists $min{$a[9]}) {
		if ($a[11]>$a[12]) {
			$min{$a[9]}=$a[12];
			$max{$a[9]}=$a[11];
		}else{
			$min{$a[9]}=$a[11];
			$max{$a[9]}=$a[12];
		}
	}elsif(exists $min{$a[9]}){
		my ($mi,$ma);
		if ($a[11]>$a[12]) {
			$mi=$a[12];
			$ma=$a[11];
		}else{
			$mi=$a[11];
			$ma=$a[12];
		}
		if ($min{$a[9]}>$mi) {
			$min{$a[9]}=$mi;
		}
		if ($max{$a[9]}<$ma) {
			$max{$a[9]}=$ma;
		}
	}
}
close I;

my $S=openfile($seq);
#open S,"$seq" or die $!;
open O,">$output" or die $!;
my ($flag,$name,$seq,$outseq,$plus,$qual,$outqual);
my $n=1;
while (my $line=<$S>) {
	if ($n%4!=1) {
		chomp $line;
	}
	if ($n%4==1) {
		if ($line=~/^@(.*)\s+/) {
			chomp $line;
			$flag=$line;
			$name=$1;
		}else {
			print "error: line $n\n";
			exit;
		}
	}elsif ($n%4==2) {
		$seq=$line;
		if (exists $min{$name} and $max{$name}) {
			my $outseq1=substr($seq,0,$min{$name});
			my $outseq2=substr($seq,$max{$name});
			my $outseq1_len=length $outseq1;
			my $outseq2_len=length $outseq2;
			if ($outseq1_len>$outseq2_len) {
				$outseq=$outseq1;
			}else {
				$outseq=$outseq2;
			}
		}else {
			$outseq=$seq;
		}
	}elsif ($n%4==3) {
		if ($line=~/^\+/) {
			$plus=$line;
		}else {
			print "error: line $n\n";
			exit;
		}
	}elsif ($n%4==0) {
		$qual=$line;
		if (exists $min{$name} and $max{$name}) {
			my $outqual1=substr($qual,0,$min{$name});
			my $outqual2=substr($qual,$max{$name});
			my $outqual1_len=length $outqual1;
			my $outqual2_len=length $outqual2;
			if ($outqual1_len>$outqual2_len) {
				$outqual=$outqual1;
			}else {
				$outqual=$outqual2;
			}
		}else {
			$outqual=$qual;
		}
		print O "$flag\n$outseq\n$plus\n$outqual\n";
	}
	$n++;
}
close O;
