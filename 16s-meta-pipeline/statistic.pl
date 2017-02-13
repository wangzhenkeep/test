if (@ARGV!=1) {die"Usage: *.pl <QC_path>\n";exit;}
@file=glob "$ARGV[0]/*/fastqc_data.txt";
open in,"$file[0]";
$mark=0;
$quality=0;
while (<in>) {
	chomp;
	if ($_=~/^Total Sequences/) {
		$Total_sequence1=(split/\s+/,$_)[2];
	}elsif ($_=~/^Sequence length/) {
		$read_length1=(split/\s+/,$_)[2];
	}elsif ($_=~/^\%GC/) {
		$GC1=(split/\s+/,$_)[1];
	}elsif ($_=~/^>>Per base sequence quality/) {
		$mark=1;
	}elsif ($mark==1 && $_=~/^>>END_MODULE/) {
		last;
	}elsif ($mark==1 && $_!~/^>>Per base sequence quality/ && $_!~/^\#/) {
		#1       33.60495107658217       34.0    34.0    34.0    34.0    34.0
		#10-14   37.17046013375516       38.0    38.0    38.0    36.0    38.0
		#50-59   36.80527491890593       38.0    37.0    38.0    34.8    38.0
		($num,$mean)=(split/\s+/,$_)[0,1];
		if ($num=~/-/) {
			($start,$end)=(split/-/,$num)[0,1];
			$quality+=($end-$start+1)*$mean*$Total_sequence1;
		}else{
			$quality+=$mean*$Total_sequence1;
		}
	}
}
close in;

open in,"$file[1]";
$mark=0;
while (<in>) {
	chomp;
	if ($_=~/^\%GC/) {
		$GC2=(split/\s+/,$_)[1];
	}elsif ($_=~/^>>Per base sequence quality/) {
		$mark=1;
	}elsif ($mark==1 && $_=~/^>>END_MODULE/) {
		last;
	}elsif ($mark==1 && $_!~/^>>Per base sequence quality/ && $_!~/^\#/) {
		#1       33.60495107658217       34.0    34.0    34.0    34.0    34.0
		#10-14   37.17046013375516       38.0    38.0    38.0    36.0    38.0
		#50-59   36.80527491890593       38.0    37.0    38.0    34.8    38.0
		($num,$mean)=(split/\s+/,$_)[0,1];
		if ($num=~/-/) {
			($start,$end)=(split/-/,$num)[0,1];
			$quality+=($end-$start+1)*$mean*$Total_sequence1;
		}else{
			$quality+=$mean*$Total_sequence1;
		}
	}
}
close in;

if ($read_length1=~/-/) {
	$read_length2=(split/-/,$read_length1)[1];
	$read_length1=$read_length2;
}
#print "$read_length1\n";
open out,">result/statistic.xls";
$total_reads=$Total_sequence1*2;
$average_quality=$quality/$total_reads/$read_length1;
$average_GC=($GC1+$GC2)/2;
printf out "$total_reads\n%0.1f\n%d%%\n",$average_quality,$average_GC;
close out;