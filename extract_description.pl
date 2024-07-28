#!/usr/bin/perl -CS
use strict;
use utf8;
use HTML::Entities;
use JSON;
use Data::Dumper;

my $row;
my @result;
push @result,
  join( "\t",
    "nr",        "PrisPerLiter", "fyllighet", "stravhet",
    "fruktsyra", "Namn",         "desc",      "Forpackning" );

##
##
my @files = `find html -type f`;
for my $filename ( sort @files ) {
    chomp $filename;

    #    print "open $filename\n";

    $filename =~ m/(\d+)/;
    my $id = $1;
    open( FILE, "<", $filename );
    my $data = join( "", <FILE> );
    close(FILE);

    #    if ( $data =~ m/<script[^>]+>(\{"props"\}.*)<\/script>/ ) {
    if ( $data =~ m/<script[^>]+>([^<]*"props".*)<\/script>/ ) {
        my $content = decode_json($1);
        my $c       = $$content{props}{pageProps}{fallback};
        my $found   = 0;
        my $desc    = $$content{props}{pageProps}{seo}{description};
        for my $key ( keys %{$c} ) {
            if ( $key =~ m/ecommerce.*product.*$id/ ) {
                $found = 1;
                my $d = $$c{$key};
                if (   $desc ne ""
                    && $$d{'categoryLevel2'} eq "Rött vin" )
                {

                    ##
                    ## Ta bort onödig beskrivning
                    ##
                    $desc =~ s/ Serveras vid .*?(\.|\z)//;
                    $desc =~ s/([\wåäö]+) och ([\wåäö]+)\.?\z/$1, $2/;

                    ##
                    ## Ta bort ogiltiga tecken
                    ##
                    $desc =~ s/[\t\n\r]/ /g;

                    ##
                    ## Alla ord efter första "inslag av" har detta som prefix
                    ##
                    if ( $desc =~ s/(inslag av )(.*)/$1/ ) {
                        my $inslag = $2;
                        $desc .= join( ", inslag av ", split( ", ", $inslag ) );
                    }

                    # print Dumper($d);
                    my $fyllighet = -1;
                    my $stravhet  = -1;
                    my $fruktsyra = -1;
                    $fyllighet = $$d{tasteClockBody}
                      if ( $$d{tasteClockBody} ne "" );
                    $stravhet = $$d{tasteClockRoughness}
                      if ( $$d{tasteClockRoughness} ne "" );
                    $fruktsyra = $$d{tasteClockFruitacid}
                      if ( $$d{tasteClockFruitacid} ne "" );
                    push @result, join(
                        "\t",
                        $id,
                        $$d{productNameBold},        #$Namn,
                        $$d{comparisonPrice} + 0,    #$PrisPerLiter,
                        $fyllighet,
                        $stravhet,
                        $fruktsyra,
                        $desc,
                        $$d{packagingLevel1} . "",    #$Forpackning
                    );
                }
            }
        }
        if ( $found == 0 && $data =~ m/clock/i ) {
            print Dumper($c);
            print "Fail $filename\n";
            exit(0);
        }
    }
}

##
## Spara resultat i en fil.
##
print "Sparar ", $#result + 1, " poster i result.csv.\n";
open( OUT, ">", "result.csv" );
binmode( OUT, ":utf8" );
print OUT join( "\n", @result ), "\n";
close(OUT);
