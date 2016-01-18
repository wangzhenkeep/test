#!/usr/bin/perl
use strict;
use warnings;

die "usage:*.pl <out_dir>\n" if (@ARGV <1);
my $file="ProjecID_Info.txt";
if (-d $ARGV[0]) {}else{
	system "mkdir $ARGV[0]";
}
my $time=`date`;
chomp $time;
open OUT, ">$ARGV[0]/$file";
print OUT "$time\n";
close OUT;
exit;


