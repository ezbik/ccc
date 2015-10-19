#!/usr/bin/perl

$APPLY=$ARGV[0];

#sub usage { print "Usage: $0 [--apply|-a]\n"; exit }

####################################
sub ccc_my {

my $src=shift;
# src can be
#       29000   =considered BYR
#       29czk   =considered CZK
my $date=shift;

if ($src=~/([\d\.]+)(\D+)/)
        {
        $src_amo=$1;
        $src_cur=$2;
        }
elsif ($src=~/([\d\.]+)/)
        {
        $src_amo=$1;
        $src_cur='byr';
        }
else { print "wrong currency $src\n"; exit }

        my $ccc_run="ccc $src_amo $src_cur usd $date";
        my $ccc=sprintf("%.2f", `$ccc_run`);
        chomp $ccc;
        if ($ccc =~ /^[\d\.]+$/ ) { return $ccc }
                else { print "bad result '$ccc' from: \`$ccc_run\`\n"; exit }
}


####################################

sub  perl_reg {

my $in=shift;
my $out=shift;

open IN, "<$in";
open OUT, ">$out";
while(<IN>)
        {
        chomp;
        $out=$_;
        if (/[\d\.]+\$/) 
                { # dollar sign detected; no actions
                } 
                else 
                {
                $out=~s@^(\d{4}\-\d{2}\-\d{2})(\s+\S+\s+)([\d\.\S]+)(.*)@"$1"."$2".ccc_my($3,$1)."\$"."\t\t[orig: ".$3."]".$4@e
                } 
        print OUT $out,"\n";
        }

close IN;
close OUT;

}
####################################

if (! -f "ambar.txt" ) {print "the file being converted, ambar.txt , doesnt exist; exit\n"; exit; } 
$TMP="/tmp/a.tmp";
perl_reg("ambar.txt", $TMP);

system ("diff -Naur ambar.txt $TMP");

if ( $APPLY =~/(-a|--apply)/  ) 
        { 
        system ("mv -v $TMP ambar.txt") 
        } 
else 
        { 
        print "\n\npass '-a' arguement to apply changes\n";
        unlink ($TMP) 
        }
	



