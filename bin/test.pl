if (@ARGV!=1) {die"Usage: *.pl <projecyID>\n";exit;}
$ARGV[0]=~s/ProjectID//;
print "$ARGV[0]\n";
