if (@ARGV!=2) {die"Usage: *.pl <path> <Project_ID>\n";exit;}
$ID_file="$ARGV[0]/$ARGV[1]";
$n=0;
open in,"$ID_file";
while (<in>) {
	chomp;
	$n+=1;
	if ($n==1) {
		system "kill -9 $_";
	}else{
		if ($_ eq "") {
			next;
		}
		print "**$_**\n";
		#root 123  3 sh /share/data_celloud/webapps/Tools/upload/15/92//pgs_20150826810565.sh
		$info=`ps -fu root | grep \" $_ \" | awk \'{\if (\$2==$_) {\print \$NF}}\'`;
		chomp $info;
		$sample_ID=(split/_/,$info)[-1];
		$sample_ID=~s/sh//;
		if ($sample_ID eq "") {
			next;
		}
		$need=`ps -fu root|\grep \"$sample_ID\"|awk \'{print \$2}\'`;
		@need=split/\n/,$need;
		foreach $need1 (@need) {
			system "kill -9 $need1";
		}
	}
}
close in;
