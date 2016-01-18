use warnings;
use strict;
use LWP::Simple;
use File::Basename qw(basename dirname); 

@ARGV > 0 or die "Usage : $0 command\n";
my $jobID_file="/share/data/Pid2Jid/Pid2Jid.txt";
open OUT, ">>$jobID_file";
my $Pid=pop @ARGV;
my $command = "@ARGV";
my ($datakey,$name,$name1,$name2,$file1,$file2,$file3,$name3);
#print "@ARGV\n$ARGV[3]\n";
open IN,"$ARGV[3]";
#print "$ARGV[2]\n";
while (<IN>) {
	chomp $_;
	my $temp=$_;
	my @a=split(/\s+/,$temp);
	if (@a==2) {
		($file1,$file2)=(split/\s+/,$temp)[0,1];
		$name=basename $file1;
		$name1=(split/\./,$name)[0];
		$name=basename $file2;
		$name2=(split/\./,$name)[0];
		$datakey=$name1.",".$name2;
	}
	elsif (@a==1) {
#		print"$a[0]\n";
		$name=basename $a[0];
		$name1=(split/\./,$name)[0];
#		print "$name1\n";
		$datakey=$name1;
	}
	elsif (@a==3) {
		($file1,$file2,$file3)=(split/\s+/,$temp)[0,1,2];
		$name=basename $file1;
		$name1=(split/\./,$name)[0];
		$name=basename $file2;
		$name2=(split/\./,$name)[0];
		$name=basename $file3;
		$name3=(split/\./,$name)[0];
		$datakey=$name1.",".$name2.",".$name3;
	}
}
my @temp = `$command`;
my %task_id;
foreach (@temp){
    $task_id{$1}=1 if $_=~ /^your job (\d+)/i;
}
print "==>stat:\t",scalar localtime,"\n";
foreach(sort keys %task_id){
	print OUT "$Pid\t$_\n";
}
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
        sleep (10);
        print "$rest work waiting...\n";
        $rest=0;

}
print "==>end :\t",scalar  localtime,"\n";
#system "python ";

$Pid=~s/ProjectID//;

#my $last_url="http://121.201.7.200:8088/celloud/project!projectRunOver?projectId=".$Pid;
my $last_url="http://www.celloud.cn/task!runOver?projectId=".$Pid."&dataNames=".$datakey;
print "$last_url\n";
my $content = get($last_url);
print "$content\n";
close OUT;
