#use utf8;
#use Encode; 
#use Encode::CN;
#use URI::Escape;


if (@ARGV!=2) {die"Usage: *.pl <input1> <input2>\n";exit;}
open in,"$ARGV[0]";
open out,">$ARGV[1]";

$num=0;
$out="";
while (<in>) {
	chomp;
	my @a=split(/\t/,$_);
	if ($a[6]>=10) {
		$num+=1;
		my $strain=(split(/strain/,$a[0]))[0];
		if ($out eq "") {
			$out=$strain."(".$a[6].")";
		}
		else{
			$out.=";\t".$strain."(".$a[6].")";
		}
	}
}
if ($num>=1) {
	$str = "感染"; 
#	Encode::_utf8_on($str);
#	print out uri_escape($str);
	print out "$str: $out\n";
}
else{
#	$str = "未检测到已有文献报道的感染菌种，是否感染未报道菌种，需与临床表征进一步确认"; 
#	print out uri_escape($str)."\n";

	print out "未检测到已有文献报道的感染菌种，是否感染未报道菌种，需与临床表征进一步确认\n";
}


close in;
close out;
