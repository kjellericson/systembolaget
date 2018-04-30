function [Nr_Namn, PrisPerLiter, fyllighet_stravhet_fruktsyra_smaker] = ...
  read_systembolaget()
% Läser in result.csv och ger tillbaka datat.

%
% Finns result.csv så använd den filen, annars ta exempel-filen.
%
filename = "result.csv";
[info, err, msg] = stat(filename);
if err == -1
  filename = "example_result.csv";
endif

output_nr_namn = "cache_nr_namn.mat";
output_pris = "cache_pris.mat";
output_smak = "cache_smak.mat";

%
% Titta om det finns en cachad variant redan
%
[info, err, msg] = stat(filename);
[info2, err2, msg2] = stat("cache.mat");
[info3, err3, msg3] = stat("read_systembolaget.m");

if err2 != -1 && info.ctime < info2.ctime && ...
   err3 != -1 && info.ctime < info3.ctime && ...
   info3.ctime < info2.ctime
   load -binary cache.mat Nr_Namn PrisPerLiter fyllighet_stravhet_fruktsyra_smaker;
  return;
endif


%
% Kolla om det finns en chache
%

wh = waitbar(0);

[nr,Namn,PrisPerLiter,fyllighet,stravhet,fruktsyra,desc] = ...
 textread(filename, "%s\t%s\t%f\t%d\t%d\t%d\t%s", "headerLines", 1, "delimiter", "\t");

%
% Plocka ut alla smaker och lagra i vocabs
%
vocabs = [];
for i = 1:length(desc)
  row = desc{i};
  [text] = strsplit(row, ",");
  for ti = 1:length(text)
    tt = strtrim(text{ti});
    if length(vocabs) == 0
      vocabs = [{tolower(tt)}];
    else
      vocabs = [vocabs; {tolower(tt)}];
    endif
  endfor
endfor
vocabs = unique(vocabs);

%
% Lagra alla smaker från vocabs i en array per vin
%
fyllighet_stravhet_fruktsyra_smaker = [];
smaker = zeros(length(nr), length(vocabs));
for i = 1:length(desc)
  row = tolower(desc{i});
  [text] = strsplit(row, ",");
  text = strtrim(text);
  text = unique(text);
  smak = zeros(rows(vocabs), 1);
  vi = 0;
  for ti = 1:length(text)
    tt = text{ti};
    do
      vi = vi + 1;
      v_str = strtrim(vocabs(vi, :));
    until strcmp(tt, v_str) == 1
    smak(vi) = 1;
  endfor
  fyllighet_stravhet_fruktsyra_smaker = ...
  [fyllighet_stravhet_fruktsyra_smaker; ...
    [fyllighet(i); stravhet(i); fruktsyra(i); smak]'];
  waitbar(i/length(desc), wh);
endfor

close(wh);
Nr_Namn = [nr Namn];

save -binary cache.mat Nr_Namn PrisPerLiter fyllighet_stravhet_fruktsyra_smaker;
