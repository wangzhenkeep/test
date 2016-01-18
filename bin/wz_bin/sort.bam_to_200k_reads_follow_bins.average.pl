#! /usr/bin/perl -w
use strict;
use List::Util qw(max min);
die "Usage: perl $0 [ bin.txt ] [ bam ] [ output ] [ length cutoff 600 ] [step_length]\n" unless ( @ARGV == 5 );

my $tab1 = $ARGV[1] ;
my $database = $ARGV[0] ;
my $output = $ARGV[2] ;
my $lengthcutoff = $ARGV[3]*0.8*1000 ;
my $count1;
my $count2;
my $tmp_num;
#`samtools view -F 4 $tab1  | awk '{print \$1"\t"\$2"\t"\$3"\t"\$4"\t"\$5"\t"\$6}' >$tab1.txt`;
open(OUT,">$output") or die ;
my (%pos,%max,%min,%num,%count);

my %bin_len;
open(D,"$database") or die ;
while (<D>) {
	chomp;
	my @b=split;
	if (!exists $num{$b[0]}{$b[1]}) {
		$num{$b[0]}{$b[1]}=1;
		@{$pos{$b[0]}{$b[1]}}=();
		push(@{$pos{$b[0]}{$b[1]}},$b[2]);
		push(@{$pos{$b[0]}{$b[1]}},$b[3]);
		$min{$b[0]}{$b[1]}=$b[2];
	}
	else{
		#$num{$b[0]}{$b[1]}=2;
		push(@{$pos{$b[0]}{$b[1]}},$b[2]);
		push(@{$pos{$b[0]}{$b[1]}},$b[3]);
		$max{$b[0]}{$b[1]}=$b[3];
	}
	#$hashchrom{$b[0]}=$b[0];
	#$hashchr{$b[0]}{$b[1]}=$b[1];
	$bin_len{$b[0]}{$b[1]}+=$b[4];
}
close D;
foreach my $key1 (keys %bin_len) {
	foreach my $key2 (keys %{$bin_len{$key1}}) {
		#if (exists $pos{$key1}{$key2}) {
			if ($bin_len{$key1}{$key2}<=$lengthcutoff) {
				delete ($bin_len{$key1}{$key2});
			}
		#}
	}
}
my $total_num=0;
my $total_num1=0;
my $total_num2=0;
open IN1,"$tab1"or die;
while (<IN1>) {
	chomp;
	my @a=split;
	my $dis=0;
	if ($a[2]=~/chrM/ or $a[2]=~/\*/) {
		next;
	}
	if ($a[4]<8) {
		next;
	}
	my @result=($a[5]=~/(\d+)M/g) ;
	my @result1=($a[5]=~/(\d+)D/g) ;
	foreach my $key1 (@result) {
		$dis+=$key1;
	}
	foreach my $key2 (@result1) {
		$dis+=$key2;
	}
	my $END=$a[3]+ $dis;
	my $key2;
MASK:	foreach my $key1 (keys %{$bin_len{$a[2]}}) {
#		if (exists $min{$a[2]}{$key1}) {
			if ($a[3]>=$min{$a[2]}{$key1}-200 and $END <= $max{$a[2]}{$key1}+200) {
				$total_num+=1;
				my $need_distance=$a[3]-@{$pos{$a[2]}{$key1}}[1];
				my $num_distance=int $need_distance/$ARGV[4];
				my $m=2*($num_distance-1)+1;
				if ($m<1) {
					$m=1;
				}elsif ($m>$#{$pos{$a[2]}{$key1}}) {
					$m=$#{$pos{$a[2]}{$key1}};
				}
				my $tmp;
				my $i;
				if (@{$pos{$a[2]}{$key1}}[$m]-$a[3]<25) {
					$total_num1+=1;
					for ($i=$m+1;$i<=@{$pos{$a[2]}{$key1}} ;$i+=1) {
						if (($i%2)==1) {
							$key2=@{$pos{$a[2]}{$key1}}[$i];
							if (($key2-$a[3]>=25 and $key2<=$END ) or ($END-$tmp >=25 and $END <=$key2)) {
								#print STDERR "$tmp\t$key2\t$a[3]\t$END\n";
								$count1+=1;
								if (!exists $count{$a[2]}{$key1}) {
									$count{$a[2]}{$key1}=1;
								}elsif (exists $count{$a[2]}{$key1} ) {
									$count{$a[2]}{$key1}+=1;
								}
								last MASK;
							}elsif ($tmp>$END) {
								$tmp_num+=1;
								last MASK;
							}
						}else{
							$key2=@{$pos{$a[2]}{$key1}}[$i];
							$tmp=$key2;
						}
					}
				}elsif (@{$pos{$a[2]}{$key1}}[$m]-$a[3]>=25) {
					$total_num2+=1;
					for ($i=$m;$i>=0 ;$i-=1) {
						if (($i%2)==0) {
							$key2=@{$pos{$a[2]}{$key1}}[$i];
							if (($tmp-$a[3]>=25 and $tmp<=$END ) or ($END-$key2 >=25 and $END <=$tmp)) {
								#print STDERR "$key2\t$tmp\t$a[3]\t$END\n";
								$count2+=1;
								if (!exists $count{$a[2]}{$key1}) {
									$count{$a[2]}{$key1}=1;
								}elsif (exists $count{$a[2]}{$key1} ) {
									$count{$a[2]}{$key1}+=1;
								}
								last MASK;
							}elsif ($tmp<$a[3]) {
								$tmp_num+=1;
								last MASK;
							}
						}else{
							$key2=@{$pos{$a[2]}{$key1}}[$i];
							$tmp=$key2;
						}
					}
				}
			}
#		}
	}
}
close IN1;

foreach my $key1 (sort{$a cmp $b} keys %bin_len) {
	foreach my $key2 (sort{$a<=>$b} keys %{$bin_len{$key1}}) {
		if (exists $count{$key1}{$key2}) {
			print OUT "$key1\t$min{$key1}{$key2}\t$max{$key1}{$key2}\t$count{$key1}{$key2}\t$key2\n";
		}
	}
}
close OUT;
#print "$count1\t$count2\n";
#print "$tmp_num\t$total_num\t$total_num1\t$total_num2\n";
