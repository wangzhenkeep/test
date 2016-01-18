use File::Basename;
use FileHandle;

if (@ARGV!=5) {die"Usage:*.pl [ bin.txt ] [ bam ] [ output ] [ length cutoff 600 ] [port]\n";exit;}

$time=`date`;
$chr=basename $ARGV[2];
#print STDERR "all start time split : $time";
$dir=dirname $ARGV[2];
system "mkdir $dir/$chr.chr";
$pwd=`pwd`;
chomp $pwd;
$bin=dirname $0;
my $tab1 = $ARGV[1] ;
my $database = $ARGV[0] ;
my $output = $ARGV[2] ;
my $lengthcutoff = $ARGV[3]*0.8*1000 ;
my %hash;
`samtools view -F 4 $tab1  | awk '{print \$1"\t"\$2"\t"\$3"\t"\$4"\t"\$5"\t"\$6}' >$tab1.txt`;
#print STDERR "samtools time :", scalar localtime(),"\n";
@chr=("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14",
		"chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY");
foreach $one (@chr) {
	open $one,">$dir/$chr.chr/$one.chr";
}

open in,"$tab1.txt" or die ;
while (<in>) {
	chomp;
	@a=split/\s/,$_;
	if ($a[2]=~/chrM/ or $a[2]=~/\*/) {
		next;
	}
	if ($a[4]<8) {
		next;
	}
	$new=$a[2];
	$new->print("$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$a[5]\n");
}
close in;

$time=`date`;
print STDERR "split End time : $time";
=cut
@slave=("root\@slave1","root\@slave2","root\@slave3");#,"root\@slave4","root\@slave5","root\@slave6");
foreach $one (@slave) {
	system "ssh $one \"rm -rf $dir\"";
	system "ssh $one \"mkdir -p $dir\"";
	system "scp -r $dir/$chr.chr $one:$dir/";
}
print STDERR "cp time :", scalar localtime(),"\n";
=cut
#print STDERR "**###**/usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[4]  --total-executor-cores 1 --master spark://master:7077 --class www.celloud.com.main.GeneCompare3 --jars /share/biosoft/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/bin/ShellCompare.jar /share/biosoft/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/bin/ShellCompare.jar  $database $dir/$chr.chr $output $ARGV[3] $chr /share/biosoft/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/shellcompare/scripts/***###***\n";
#system "/usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[4] --total-executor-cores 1 --master spark://master:7077 --class www.celloud.com.main.GeneCompare3 --jars /share/biosoft_spark/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/bin/ShellCompare.jar /share/biosoft_spark/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/bin/ShellCompare.jar  $database $dir/$chr.chr $output $ARGV[3] $chr /share/biosoft_spark/perl/wangzhen/PGS/High_PPI/gDNA/wz_bin/shellcompare/scripts/";
#print STDERR "**###**/usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[4]  --total-executor-cores 1 --master spark://master:7077 --class www.celloud.com.main.GeneCompare3 --jars /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar  $database $dir/$chr.chr $output $ARGV[3] $chr /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/***###***\n";
system "/usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[4] --driver-memory 2G  --total-executor-cores 1 --master spark://master:7077 --class www.celloud.com.main.GeneCompare3 --jars /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar  $database $dir/$chr.chr $output $ARGV[3] $chr $bin/";

$mark_size=`ls -l $ARGV[2] | awk {'print \$5'}`;
chomp $mark_size;
while ($mark_size==0) {
	sleep 30;
	system "/usr/lib/spark/bin/spark-submit --conf spark.ui.port=$ARGV[4] --driver-memory 2G  --total-executor-cores 1 --master spark://master:7077 --class www.celloud.com.main.GeneCompare3 --jars /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar /share/biosoft/perl/wangzhen/PGS/bin/wz_bin/ShellCompare.jar  $database $dir/$chr.chr $output $ARGV[3] $chr $bin/";
	print STDERR "***********slepp 5s\n";
	#sleep 5;
	$mark_size=`ls -l $ARGV[2] | awk {'print \$5'}`;
	chomp $mark_size;
}

$time=`date`;
#print STDERR "all End time split : $time";
