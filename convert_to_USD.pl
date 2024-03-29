#!/usr/bin/perl

$default_src_cur="czk";

$APPLY=$ARGV[0];

#sub usage { print "Usage: $0 [--apply|-a]\n"; exit }

####################################
sub ccc_my {

my $src=shift;
# src can be
#       29000   =considered BYR
#       29czk   =considered CZK
my $date=shift;
my $default_src_cur=shift;

if ($src=~/([\d\.]+)(\D+)/)
        {
        $src_amo=$1;
        $src_cur=$2;
        }
elsif ($src=~/([\d\.]+)/)
        {
        $src_amo=$1;
        $src_cur=$default_src_cur;
        }
else { print "wrong currency $src\n"; exit }

        my $ccc_run="ccc $src_amo $src_cur usd $date";
        my $ccc=`$ccc_run`;
        chomp $ccc;
        #print "===$ccc===\n";
        if ($ccc =~ /^[\d\.]+$/ ) 
                { 
                $ccc=sprintf("%.2f", `$ccc_run`);
                return $ccc;
                }
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
        if (/^DEFAULT_CURRENCY=(\S+)/) {$default_src_cur=$1}
        if (/[\d\.]+\$/) 
                { # dollar sign detected; no actions
                } 
                else 
                {
                $out=~s@^(\d{4}\-\d{2}\-\d{2})(\s+\S+\s+)([\d\.\S]+)(.*)@"$1"."$2".ccc_my($3,$1,$default_src_cur)."\$"."\t\t[orig: ".$3."]".$4@e
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
	



