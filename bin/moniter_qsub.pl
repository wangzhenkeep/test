use warnings;
use strict;
@ARGV > 0 or die "Usage : $0 command\n";
my $Pid=pop @ARGV;
my $command = "@ARGV";
my $jobID_file="/share/data/Pid2Jid/Pid2Jid.txt";
print "$command\n";
my @temp = `$command`;
my %task_id;
foreach (@temp){
    $task_id{$1}=1 if $_=~ /^your job (\d+)/i;
}
print "==>stat:\t",scalar localtime,"\n";
open OUT, ">>$jobID_file";
foreach(sort keys %task_id){
	print OUT "$Pid\t$_\n";
}
close OUT;
#sleep (1);
my $over=0;
my $rest=0;
until ($over++){
    @temp = `qstat`;
    foreach (@temp){
        if($_=~/^\s*(\d+)/ && exists $task_id{$1} ){
                        $rest++;
             $over=0;
        }
    }
        sleep (60);
        print "$rest work waiting...\n";
        $rest=0;

}
print "==>end :\t",scalar  localtime,"\n";
