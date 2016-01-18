#! /usr/bin/perl -w
use strict;
use List::Util qw(max min);
#die "Usage: perl $0 [ bam ] [ database ] [ output ] [ length cutoff 600 ]" unless ( @ARGV == 4 );
die "Usage: perl $0 [ bin.txt ] [ bam ] [ output ] [ length cutoff 600 ]" unless ( @ARGV == 4 );

my $tab1 = $ARGV[1] ;
my $database = $ARGV[0] ;
my $output = $ARGV[2] ;
my $lengthcutoff = $ARGV[3]*0.8*1000 ;
my %hash;
#`samtools view -F 4 $tab1  | awk '{print \$1"\t"\$2"\t"\$3"\t"\$4"\t"\$5"\t"\$6}' >$tab1.txt`;

#open(IN1,"$tab1.txt") or die ;
open IN1,"$tab1"or die;
open(D,"$database") or die ;
open(OUT,">$output") or die ;
$/="\n";
my (%pos,%max,%min,%hashchrom,%hashchromID,%num,%count,%hashchr,%array);

my %bin_len;
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
		$num{$b[0]}{$b[1]}+=1;
#		$beg{$b[0]}{$b[1]}{$num{$b[0]}{$b[1]}}=$b[2];
#		$end{$b[0]}{$b[1]}{$num{$b[0]}{$b[1]}}=$b[3];
		push(@{$pos{$b[0]}{$b[1]}},$b[2]);
		push(@{$pos{$b[0]}{$b[1]}},$b[3]);
		$max{$b[0]}{$b[1]}=$b[3];
	}
	$hashchrom{$b[0]}=$b[0];
#	$hashchromID{$b[1]}=$b[1];
	$hashchr{$b[0]}{$b[1]}=$b[1];
	$bin_len{$b[0]}{$b[1]}+=$b[4];
}
foreach my $key1 (keys %hashchrom) {
	foreach my $key2 (keys %{$hashchr{$key1}}) {
		if (exists $pos{$key1}{$key2}) {
			#$max{$key1}{$key2}=max @{$pos{$key1}{$key2}};
			#$min{$key1}{$key2}=min @{$pos{$key1}{$key2}};
			#if ($max{$key1}{$key2}-$min{$key1}{$key2} < $lengthcutoff) {
			#	delete ($hashchr{$key1}{$key2});
			#}
#			@{$array{$key1}}[$min{$key1}{$key2}..$max{$key1}{$key2}]=$key2;
#			print "$key1\t$key2\t$max{$key1}{$key2}\t$min{$key1}{$key2}\n";
   		    if ($bin_len{$key1}{$key2}<=$lengthcutoff) {
			    delete ($hashchr{$key1}{$key2});
		    }
		}
	}
}

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
#	print "$a[3]\t$END\t$a[2]\t$a[1]\t$min{$a[2]}{$a[1]}\t$max{$a[2]}{$a[1]}\n";
MASK:	foreach my $key1 (keys %{$hashchr{$a[2]}}) {
		if (exists $min{$a[2]}{$key1}) {
			#if ($a[3]>=$min{$a[2]}{$key1} and $END <= $max{$a[2]}{$key1}) {
            if ($a[3]>=$min{$a[2]}{$key1}-200 and $END <= $max{$a[2]}{$key1}+200) {
				my $num=@{$pos{$a[2]}{$key1}};
#				my @POS;
#				push(@POS,@pos{$a[2]}{$key1});
				my $m=1;
				my $tmp;
				for my $key2 (@{$pos{$a[2]}{$key1}}){
#					print "$key2";
					 if(($m%2)==0){
						#if (($key2-$a[3]>=25 and $a[3] >=$tmp ) or ($END-$tmp >=25 and $END <=$key2)) {
						if (($key2-$a[3]>=25 and $key2<=$END ) or ($END-$tmp >=25 and $END <=$key2)) {
						
							if (!exists $count{$a[2]}{$key1}) {
								$count{$a[2]}{$key1}=1;
							}
							elsif (exists $count{$a[2]}{$key1} ) {
								$count{$a[2]}{$key1}+=1;
							}
						last MASK;
						}
					 }
					 else{
						 $tmp=$key2;
					 }
					 $m++;
				}
=cut
				for (my $i=0;$i<$num;$i+=2) {
					if ( (@{$pos{$a[2]}{$key1}}[$i+1]-$a[2]>=25 and $a[2] >= @{$pos{$a[2]}{$key1}}[$i]) or ($END - @{$pos{$a[2]}{$key1}}[$i]>=25 and $END <= @{$pos{$a[2]}{$key1}}[$i+1]) {
						if (!exists $count{$a[2]}{$key1}) {
							$count{$a[2]}{$key1}=1;
						}
						elsif (exists $count{$a[2]}{$key1} ) {
							$count{$a[2]}{$key1}+=1;
						}
					last MASK;
					}
				}
=cut
			}
		}
	}
=cut
	if (!exists $count{$a[2]}{${$array{$a[2]}}[$a[3]]}) {
		$count{$a[2]}{${$array{$a[2]}}[$a[3]]}=1;
	}
	elsif (exists $count{$a[2]}{${$array{$a[2]}}[$a[3]]} ) {
		$count{$a[2]}{${$array{$a[2]}}[$a[3]]}+=1;
	}
=cut

#	print OUT "$_\t$dis\t$END\n";
}


foreach my $key1 (sort{$a cmp $b} keys %hashchrom) {
#	print "$key1\n";
	foreach my $key2 (sort{$a<=>$b} keys %{$hashchr{$key1}}) {
#		print "$key2\n";
		if (exists $count{$key1}{$key2}) {
			print OUT "$key1\t$min{$key1}{$key2}\t$max{$key1}{$key2}\t$count{$key1}{$key2}\t$key2\n";
		}
	}

}

close IN1;
close OUT;


=cut
sub min {
        my ($x1,$x2)=@_;
        my $min;
        if ($x1 < $x2) {
                $min=$x1;
        }
        else {
                $min=$x2;
        }
        return $min;
}

sub max {
        my ($x1,$x2)=@_;
        my $max;
        if ($x1 > $x2) {
                $max=$x1;
        }
        else {
                $max=$x2;
        }
        return $max;
}


sub cat

 #function:quit redundance get project length
 #input:(@array)
 #output:($length_project)
 #for example (1,3,4,7,5,8,10,12)->(1,8,10,12)
 {
  my(@input) = @_;
  my $merge = 1;
  my $i = 0;
  my @output = ();
  my %hash = ();
  my $each = 0;
  my $begin = 0;
  my $end = 0;
  my $length_project = 0;
  my ($Qb,$Qe,$temp);

  for ($i=0;$i<@input;$i+=2)
  {
   $Qb = $input[$i];
   $Qe = $input[$i+1];
#       print "$Qb\t$Qe\n";
   if($Qb > $Qe) { $temp = $Qb; $Qb = $Qe; $Qe = $temp; }
   if(defined($hash{$Qb})) { if($hash{$Qb} < $Qe) { $hash{$Qb} = $Qe; }
   }
   else { $hash{$Qb} = $Qe; }
   $Qb = 0;
  }

  foreach $each (sort {$a <=> $b} keys %hash)
  {
   if($begin == 0)
   {
    $begin = $each;
    $end = $hash{$each};
   }
   else
   {
    if($hash{$each} > $end)
    {
     if($each > $end + $merge)
     {
        push(@output,$begin);
        push(@output,$end);
     $length_project += $end - $begin + 1;

      $begin = $each;
      $end = $hash{$each};
     }
     else { $end = $hash{$each}; }
    }
   }
  }
  push(@output,$begin);
  push(@output,$end);
  $length_project += $end - $begin + 1;

  %hash = ();
  undef(%hash);

  return($length_project);
#  return($length_project);
 }
=cut

