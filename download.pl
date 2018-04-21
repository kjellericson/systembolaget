#!/usr/bin/perl
use HTML::Entities;

##
## Hämta senaste sortimentslistan.
##
print "########## Hämta sortimentet\n";
my $data = `curl -L -A Mozilla https://www.systembolaget.se/api/assortment/products/xls`;
$data =~ s/[\r\n]//gs;


print "########## Extrahera data\n";
my @sortiment;
while ($data =~ s-<tr.*?>(.*?)</tr>--s) {
    my $row = $1;

    ##
    ## Bort med html.
    ##
    $row =~ s/^\s*?(<th.*?>|<td>)//s;
    $row =~ s/(<th.*?>|<td>)/\t/gs;
    $row =~ s/<.*?>//g;
    $row = decode_entities($row);

    ##
    ## Vi sparar bara röda viner.
    ##
    if ($row =~ m/R.tt vin/) {
	push @sortiment, $row;
    }
}

##
## Spara data i fil (för debugging)
##
open(OUT, ">sortiment.txt");
for (@sortiment) {
    print OUT $_, "\n";
}
close(OUT);

##
## Skapa katalog för att spara filer
##
mkdir "html";

##
## Hämta alla html-filer för varje artikel
##
print "########### Download html\n";
for my $row (@sortiment) {
    chomp $row;

    ##
    ## Splitta raden enligt Systembolagets beskrivning.
    ##
    my ($nr, $Artikelid, $Varnummer, $Namn, $Namn2, $Prisinklmoms, $Pant, $Volymiml, $PrisPerLiter, $Saljstart, $Utgatt, $Varugrupp, $Typ, $Stil, $Forpackning, $Forslutning, $Ursprung, $Ursprunglandnamn, $Producent, $Leverantor, $Argang, $Provadargang, $Alkoholhalt, $Sortiment, $SortimentText, $Ekologisk, $Etiskt, $EtisktEtikett, $Koscher, $RavarorBeskrivning) = split("\t", $row);
    my $filename = "html/$nr.html";

    ##
    ## Hämta fil om vi inte redan har den, samt om den inte utgått.
    ##
    if ($Utgatt eq "0" && !-f $filename) {
	my $search = "https://www.systembolaget.se/api/productsearch/search/sok-dryck/?searchquery=$nr&sortdirection=Ascending&site=all&fullassortment=1";
	my $res = `curl -s -A Mozilla "$search"`;
	if ($res =~ m/(\/dryck\/[^"]+-$nr)\"/) {
	    my $url = "https://www.systembolaget.se$1";
	    print join(", ", $nr, $Namn, $Utgatt, $url), "\n";
	    `curl -A Mozilla -s "$url" >html/$nr.html`;
	}
    }
} 
