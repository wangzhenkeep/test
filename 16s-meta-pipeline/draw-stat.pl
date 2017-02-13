if (@ARGV!=2) {die"Usage: *.pl <input1> <input2>\n";exit;}
open in,"$ARGV[0]";
open in1,"$ARGV[1]";

while (<in>) {
	chomp;
	my @a=split;
	if ($a[6]>=10) {
		my $strain=split(/16S/,$a[0])[0];
		print out "$strain\t";
	}
}
print out "\n";



close in;
close out;
