#!/usr/bin/perl -CS
use strict;
use utf8;
use HTML::Entities;

my $row;
my @result;
push @result, join("\t", "nr", "PrisPerLiter", "fyllighet", "stravhet", "fruktsyra", "Namn", "desc");

##
## Använd sortiment-filen för att veta vilka filer som kan läsa in.
##
open(IN, "<sortiment.txt");
while ($row = <IN>) {
    chomp $row;

    ##
    ## Splitta raden enligt Systembolagets beskrivning.
    ##
    my ($nr, $Artikelid, $Varnummer, $Namn, $Namn2, $Prisinklmoms, $Pant, $Volymiml, $PrisPerLiter, $Saljstart, $Utgatt, $Varugrupp, $Typ, $Stil, $Forpackning, $Forslutning, $Ursprung, $Ursprunglandnamn, $Producent, $Leverantor, $Argang, $Provadargang, $Alkoholhalt, $Sortiment, $SortimentText, $Ekologisk, $Etiskt, $EtisktEtikett, $Koscher, $RavarorBeskrivning) = split("\t", $row);

    ##
    ## Läs in html-filen om den finns
    ##
    my $filename = "html/$nr.html";
    if (-f $filename) {
	open(FILE, "<", $filename);
	my $data = join("", <FILE>);

	##
	## Ignorera delar i sortimentet som inte är provat
	##
	if ($data !~ m/inte provad av Systembolaget/ &&
	    $data !~ m/Varan finns i begr/) {

	    ##
	    ## Extrahera beskrivningen
	    ##
	    if ($data =~ m/<p class="description ">(.*?)<\/p>/) {
		my $desc = decode_entities($1);

		##
		## Ta bort onödig beskrivning
		##
		$desc =~ s/ Serveras vid .*?(\.|\z)//;
		$desc =~ s/([\wåäö]+) och ([\wåäö]+)\.?\z/$1, $2/;

		##
		## Ta bort ogiltiga tecken
		##
		$desc =~ s/\t//g;

		##
		## Alla ord efter första "inslag av" har detta som prefix
		##
		if ($desc =~ s/(inslag av )(.*)/$1/) {
		    my $inslag = $2;
		    $desc .= join(", inslag av ", split(", ", $inslag));
		}
		
		##
		## Hitta fyllighet, strävhet och fruktsyra
		##
		my $fyllighet = -1;
		if ($data =~ m/smakklocka fyllighet med v..rde (\d+)/) {
		    $fyllighet = $1;
		}
		my $stravhet = -1;
		if ($data =~ m/smakklocka str..vhet med v..rde (\d+)/) {
		    $stravhet = $1;
		}
		my $fruktsyra = -1;
		if ($data =~ m/smakklocka fruktsyra med v..rde (\d+)/) {
		    $fruktsyra = $1;
		}
		
		push @result, join("\t", $nr, $Namn, $PrisPerLiter, $fyllighet, $stravhet, $fruktsyra, $desc);
	    } else {
		print "$nr hittar ingen beskrivning.\n";
	    }
	}
	close(FILE);
    }
}

##
## Spara resultat i en fil.
##
print "Sparar ", $#result +1, " poster i result.csv.\n";
open(OUT, ">", "result.csv");
binmode(OUT, ":utf8");
print OUT join("\n", @result);
close(OUT);
