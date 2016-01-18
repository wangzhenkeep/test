if (@ARGV!=7) {die"Usage: *.pl <out_log> <sort.pl> <bins.200k.txt> Read<*.bam> <bam.raw.cnt> <200> <dir>\n";exit;}
system "rm -rf $ARGV[6]/out_log";
system "perl $ARGV[1] $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5] $ARGV[6] 1>>$ARGV[6]/out_log 2>>$ARGV[6]/out_log\n\n";