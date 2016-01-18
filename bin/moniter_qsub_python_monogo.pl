use warnings;
use strict;
use File::Basename;


@ARGV > 0 or die "Usage : $0 command\n";
my $bin_path=dirname $0;
my $Pid=pop @ARGV;
my $command = "@ARGV";
print "****@ARGV****\n";
#my @temp;
my @temp = `$command`;
my %task_id;
foreach (@temp){
        #print "****$_*****\n";
        chomp;
        $task_id{$_}=1 if $_ ne "";
}
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
my $python_bin_path=$bin_path;
$python_bin_path=~s/bin$/python/;
my $absolute_path=(split/\s+/,$command)[-1];
system "python /share/biosoft/perl/PGS_MG/python1/socket_client.py $absolute_path $Pid";
print STDERR "************python /share/biosoft/perl/PGS_MG/python1/isTrue.py $ARGV[-1]/$Pid.log $ARGV[-1]  $Pid\n";
#system "python /share/biosoft/perl/PGS_MG/python1/isTrue.py $ARGV[-1]/$Pid.log $ARGV[-1]  $Pid";
