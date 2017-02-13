die "usage: $0 [input_fq] [forward_fq] [reverse_fq] [single_fq]\n" if @ARGV!=4;
open IN, "$ARGV[0]" or die "can't open $ARGV[0]";
open FOR, ">$ARGV[1]" or die "can't open $ARGV[1]";
open RE, ">$ARGV[2]" or die "can't open $ARGV[2]";
open SIN, ">$ARGV[3]" or die "can't open $ARGV[3]";

$num=0;
while (<IN>) {
    chomp;
    $fq[$num]=$_;
    $hash{$num}=0;
    if (/^@/) {
        $name[$num]=$_;
        $name[$num]=~s/_[12]$//;
    }
    $num++;
}
close IN;

for ($j=0;$j<=@fq;$j++) {
    if ($fq[$j]=~/^@.*_1$/) {
        for ($k=$j+1;$k<=@fq;$k++) {
            if ($fq[$k]=~/^@.*_2$/) {
                if (($name[$k] eq $name[$j]) and ($hash{$j}==0) and ($hash{$k}==0)) {
                        print FOR "$fq[$j]\n$fq[$j+1]\n$fq[$j+2]\n$fq[$j+3]\n";
                        print RE "$fq[$k]\n$fq[$k+1]\n$fq[$k+2]\n$fq[$k+3]\n";
                    $hash{$j}++;
                    $hash{$k}++;
                }
            }
        }
    }
}

foreach $key (0.. $#fq) {
   if ($fq[$key]=~/^@/) {
       next if ($hash{$key}!=0);
       print SIN "$fq[$key]\n$fq[$key+1]\n$fq[$key+2]\n$fq[$key+3]\n";
    }
}

close FOR;
close RE;
close SIN;
