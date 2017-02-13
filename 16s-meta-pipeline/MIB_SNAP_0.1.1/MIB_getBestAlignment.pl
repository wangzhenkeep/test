#!/usr/bin/perl
#
#
#	MIB_getBestAlignment.pl
#
#	This program was to keep the best results from blast alignment according to the bitscore value.
#	
#	if two records with the same bitscore, then both will be kept.
#
#	usage:	
#		MIB_getBestAlignment.pl <BLAST_output_fmt_6> 
#
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-08-05


use strict;

open FL, $ARGV[0] or die "Cannot open file: $!\n";
open OUT, ">$ARGV[0].best";

my $last_bit = 0;
my $cur_bit = 0;
my %qseqid_sseqid_bit;
my $last_qseq = "0";
my $cur_qseq = "0";
my (@temp, $record, $diff);

while (<FL>) {
	chomp;
	$record = $_;
	@temp = split /\t/, $record;
	$cur_qseq = $temp[0];
	$cur_bit = $temp[14];
	$diff = $cur_bit - $last_bit;
	#print "$diff\n";
	#print "$last_bit\n";
	if (($cur_qseq eq $last_qseq) && ($diff >= 0)) {
		print OUT "$record\n";
		$last_bit = $cur_bit;
	} elsif ($cur_qseq ne $last_qseq) {
		print OUT "$record\n";
		$last_bit = $cur_bit;
	}	
	$last_qseq = $cur_qseq;	
	#my %sseqid_bitscore;
	#my $qseqid_sseqid{$temp[0]} = $temp[1];
	#my $sseqid_bitscore{$temp[1]} = $temp[-1];
}

close FL;
close OUT;
