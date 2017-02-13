die "Usage: perl $0 [input] [output]\n" if @ARGV!=2;
open (IN, "$ARGV[0]") or die "cannot open $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "cannot open $ARGV[1]\n";


$mark=0;
while (<IN>) {
    chomp;
    @a=split(/\t/,$_);
	if ($_=~/Total_sequences/) {
		$sum=$a[1];
#		print OUT "$_\n";
	}
	elsif ($_=~/Others/) {
		if ($mark==0) {
			$out=sprintf "%0.3f", ($a[1]/$sum*100);
#			print OUT "$a[0]\t$out\n";
			$hash{$a[0]}=$out;
			$mark=1;
		}
	}
	else {
			$out=sprintf "%0.3f", ($a[1]/$sum*100);
			$hash{$a[0]}=$out;
#			print OUT "$a[0]\t$out\n";
	}
}

foreach my $key (sort{$hash{$b}<=>$hash{$a}} keys%hash) {
	print OUT "$key\t$hash{$key}\n";
}
close IN;
close OUT;
