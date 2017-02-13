#!/usr/bin/perl -w
#
#	htmlGen.pl
#
#	This program will collect all the information for final view in html.
#	
#	htmlGen.pl <.table> <NGS> <total_time> <mib_dir>
#
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-08-05
### Copyright (C) 2015 Yang Li - All Rights Reserved
use strict;
use warnings;

use Template;

if ( @ARGV < 4 ) {
	die "usage: $0 <.table> <NGS> <total_time> <mib_dir>";
} 

open my $fh, "$ARGV[0]" or die;
my $header = <$fh>;
chomp $header;
my @h = split /\t/, $header;
my @lines;
#my %pics_phygo;
my %pics_covplot;
while (my $line = <$fh>) {
    chomp $line;
    my @f = split /\t/, $line;
#print "$f[1]\n";
    my @covplot = glob("covplot.$f[1].*.png");
#    if (@files) {
#        print $files[0], "\n";
#        $pics{$f[1]} = $files[0];
#    }
    if (@covplot){
        print $covplot[0], " Loaded\n";
        $pics_covplot{$f[1]} = $covplot[0];
    }
    
    push @lines, \@f;
}
my $report_name = "$ARGV[1]";
my $cur_time = `date`;
my $mib_dir = "$ARGV[3]";
my $t = Template->new({INCLUDE_PATH => "$mib_dir"});
my $total_time = "$ARGV[2]";
$t->process("mib.tt", { 
	h => \@h, 
	lines => \@lines, 
	pics_covplot => \%pics_covplot, 
	report_name => $report_name, 
	cur_time => $cur_time, 
	total_time => $total_time}, "MIB_report.html") || die $t->error();

