#!/usr/bin/perl

##
## Hämta senaste sortimentslistan.
##
print "########## Hämta sortimentet\n";
my $data =
  `curl -L -A Mozilla https://www.systembolaget.se/sitemap-produkter-vin.xml`;
$data =~ s/[\r\n]//gs;

print "########## Extrahera data\n";
my @urls;
while ( $data =~ s-<loc>(.*?)</loc>--s ) {
    my $url = $1;

    if ( $url =~ m/-(\d+)\// ) {
        $nr = $1;
        my $filename = "html/$nr.html";
    }

    ##
    ## Hämta fil om vi inte redan har den, samt om den inte utgått.
    ##
    if ( !-f $filename ) {
        print "Download $url\n";
        `curl -A Mozilla -s "$url" >html/$nr.html`;
    }
}
