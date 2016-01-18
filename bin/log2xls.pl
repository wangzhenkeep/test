#!/usr/bin/perl
use strict;
use warnings;

die "usage: *.pl <in.log> <in.Statistics> <out.xls> <Name>\n" if (@ARGV < 4);
my $file=$ARGV[0];
$file=~s/(\S+)\/\S+\.log/$1/;
if(-e "$file/no_enough_reads.txt"){
system "mv $file/no_enough_reads.txt $file/no_enough_reads.xls";
open IN,"$file/no_enough_reads.xls";
my $temp=<IN>;
open OUT,">$ARGV[1]";
print OUT "Raw_Reads\tNew_Reads\tRaw_Reads(2X)%\tMap_Ratio(%)\trmdup_Ratio(%)\n";
print OUT "no enough reads! $temp\n";
close OUT;
close IN;
exit;
}
open IN,"$ARGV[0]";
#my @temp=<IN>;
#foreach  (@temp) {
#	chomp;
#}
#my $raw=$temp[0];$raw=~s/^(\d+)\s+.+/$1/;
#my $new=$temp[1];$new=~s/^(\d+)\s+.+/$1/;
#my $x2=$temp[2];$x2=~s/^(\S+)\%\s+.+/$1/;
#my $map=$temp[5];$map=~s/^(\S+)\%\s+.+/$1/;
#my $rmdup=$temp[6];$rmdup=~s/^(\S+)\%\s+.+/$1/;
#my $winsize=$temp[8];$winsize=~s/window size:\s+(\d+kbp)/$1/; 

my $raw;
my $new;
my $x2;
my $map;
my $rmdup;
my $winsize;
my $MT;
my $sit="Map_Reads";
my $Mm="";
while (<IN>) {
	chomp;
	if (/raw reads num/) {
#		$raw=$_;$raw=~s/^(\d+)\s+.+/$1/;
	}elsif (/new reads num/) {
#		$new=$_;$new=~s/^(\d+)\s+.+/$1/;
	}elsif (/generate 2 X new reads/) {
#		$x2=$_;$x2=~s/^(\S+)\%\s+.+/$1/;
	}elsif (/reads map ratio/) {
		$_=~/^(\S+)\% = (\d+) \/ (\d+) reads map ratio/;
		$raw=$3;$new=$2;$map=$1;$Mm=$new;
	}elsif (/rmdup ratio/) {
		$rmdup=$_;$rmdup=~s/^(\S+)\%\s+.+/$1/;
	}elsif (/^window size/) {
		$winsize=$_;$winsize=~s/window size:\s+(\d+)kbp/$1/; 
	}elsif (/reads MT ratio/) {
		$_=~/^(\S+)\% = (\d+) \/ (\d+) reads MT ratio/;
		$MT=$1;$sit="MT_ratio(%)";$Mm=$MT;
	}
}

close IN;
open IN,"$ARGV[1]";
my @temp=<IN>;
close IN;
my $GC;
my $STD;
foreach my $x (@temp) {
	if ($x=~/GC Ratio/) {
		$x=~/^(\S+)%\s+=/;
		$GC=$1;
	}
	if ($x=~/^Genome STDEV:\s+(\S+)/) {
		$STD=$1;
	}
}
my @test=split/\s+/,$temp[1];
my $dup=$test[2];

open OUT,">$ARGV[2]";
if (exists $ARGV[3]){print OUT "$ARGV[3]\n";}
if(exists $ARGV[4]){
	print OUT "Total_Reads\t$sit\tMap_Ratio(%)\tDuplicate(%)\tGC_Count(%)\t\*SD\n";
	print OUT "$raw\t$Mm\t$map\t$rmdup\t$GC\t$STD\n";
	print OUT "*The result is reliable if SD < $ARGV[4]";
}else{
	print OUT "Total_Reads\t$sit\tMap_Ratio(%)\tDuplicate(%)\tGC_Count(%)\n";
        print OUT "$raw\t$Mm\t$map\t$rmdup\t$GC\n";

}


close OUT;
