use warnings;
use strict;
use File::Basename;
use LWP::Simple;

@ARGV > 0 or die "Usage : $0 command\n";
my $bin_path=dirname $0;
my $Pid=pop @ARGV;
my $command = "@ARGV";
my $ID_file="$ARGV[-1]/$Pid";
#print "****@ARGV****\n";
#my @temp;
my @temp = `$command`;
my %task_id;
open OUT,">$ID_file";
print OUT "$$\n";
foreach (@temp){
        #print "****$_*****\n";
        chomp;
        $task_id{$_}=1 if $_ ne "";
	print OUT "$_\n";
}
close OUT;
print "==>stat:\t",scalar localtime,"\n";
#sleep (1);
my $over=0;
my $rest=0;
until ($over++){
        @temp = `ps x |grep \"sh\"|awk \'{print \$1}\'`;
        foreach (@temp){
                if($_=~/^\s*(\d+)/ && exists $task_id{$1} ){
                        $rest++;
                        $over=0;
                }
        }
        sleep (10);
        print "$rest work waiting...\n";
        $rest=0;
}
print "==>end :\t",scalar  localtime,"\n";
$Pid=~s/ProjectID//;
#print "1#####\n";
my $last_url="http://10.1.0.6:8080/celloud/project!projectRunOver?projectId=".$Pid;
#print "2#####\n";
my $content = get($last_url);
#print "#$content#\n";
#print "3####\n";
