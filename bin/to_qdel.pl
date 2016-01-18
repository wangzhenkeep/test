#! /usr/bin/perl -w
use strict;

if (@ARGV != 2){die "usage : *.pl <result_path> <ProjectID>\n";exit;};
my $file="$ARGV[0]/$ARGV[1]";
open IN, "$file";
while (<IN>){
	chomp;
	my $taskid = (split/\s+/, $_)[1];
	my $info=`qstat|grep \"$taskid\"`;
	#print "**$info**\n";
	while ($info ne "") {
		system "qdel $taskid";
		sleep 1;
		$info=`qstat|grep "$taskid"`;
		#print "***$info***\n";
	}
}
close IN;
