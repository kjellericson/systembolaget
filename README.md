# systembolaget
Hämta hem information från Systembolagets sortiment.

Det är inriktiat på röda viner just nu.  Det är inte svårt att utöka det,
men jag är för ögonblicket inte intresserad av övrigt sortiment.

Systembolaget har ett api där man kan få ut information om deras sortiment.
Tyvärr innehåller det inte smakbeskrivningar och det är dessa jag vill ha.

# Initiera

Kör skriptet download.pl med `make step1-download`.  Det hämtar hem aktuellt sortiment, hämtar hem alla
sidor rörande röda viner och lagrar i katalogen html.


# Extrahera

Kör skriptet extract_description.pl med `make step2-extract`.  Det kommer skapa filen "result.csv".
Jag har checkat in filen "example_result.csv" för den som inte vill köra
alla stegen.

# Octave

Kör "octave systembolaget.m" med `make step3-octave` från prompten, eller "systembolaget" innefrån
Octave.

# Output

Filen output.html innehåller data som du kan titta på.
Öppna upp den i din webbläsare.
