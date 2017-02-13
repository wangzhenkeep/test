die "Usage: perl $0 [input] [output]\n" if @ARGV!=2;
open (IN, "$ARGV[0]") or die "cannot open $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "cannot open $ARGV[1]\n";

$n=1;
while (<IN>) {
    chomp;
    ($name,$num)=(split(/\t/,$_))[0,1];
    $sum+=$num;
    $NUM[$n]=$num;
    $NAME[$n]=$name;
    $n++;
}
$others=100;
quicksort("1","$n");
for ($i=$n;$i>=$n-4;$i--) {
    $per=sprintf "%0.3f", ($NUM[$i]*100/$sum);
#    print OUT "$NAME[$i]\t$per\n";
	$hash{$NAME[$i]}=$per;
    $others-=$per;
}
#print OUT "others\t$others\n";
	$hash{"others"}=$others;
foreach my $key (sort{$hash{$b}<=>$hash{$a}} keys%hash) {
	print OUT "$key\t$hash{$key}\n";
}

sub quicksort {
    my ($left,$right)=@_;
    if ($left>$right){return;}
    $temp=$NUM[$left];
    $tmp_name=$NAME[$left];
    $i=$left;
    $j=$right;
    while ($i!=$j) {
        while ($NUM[$j]>=$temp && $i<$j) {
            $j--;
        }
        while ($NUM[$i]<=$temp && $i<$j) {
            $i++;
        }
        if ($i<$j) {
            $t=$NUM[$i];
            $NUM[$i]=$NUM[$j];
            $NUM[$j]=$t;
            $t_name=$NAME[$i];
            $NAME[$i]=$NAME[$j];
            $NAME[$j]=$t_name;
        }
    }
    $NUM[$left]=$NUM[$i];
    $NUM[$i]=$temp;
    $NAME[$left]=$NAME[$i];
    $NAME[$i]=$tmp_name;
    quicksort($left,$i-1);
    quicksort($i+1,$right);
}



close IN;
close OUT;
