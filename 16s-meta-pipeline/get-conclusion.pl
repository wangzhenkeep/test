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
	$str = "��Ⱦ"; 
#	Encode::_utf8_on($str);
#	print out uri_escape($str);
	print out "$str: $out\n";
}
else{
#	$str = "δ��⵽�������ױ����ĸ�Ⱦ���֣��Ƿ��Ⱦδ�������֣������ٴ�������һ��ȷ��"; 
#	print out uri_escape($str)."\n";

	print out "δ��⵽�������ױ����ĸ�Ⱦ���֣��Ƿ��Ⱦδ�������֣������ٴ�������һ��ȷ��\n";
}


close in;
close out;
