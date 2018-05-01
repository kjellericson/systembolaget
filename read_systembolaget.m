function [Nr_Namn, PrisPerFlaska, fyllighet_stravhet_fruktsyra_smaker, beskrivning] = ...
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

%
% Titta om det finns en cachad variant redan
%
[data_info, data_err] = stat(filename);
[cache_info, cache_err] = stat("cache.mat");
[script_info, script_err] = stat("read_systembolaget.m");

if cache_err != -1 && data_info.ctime < cache_info.ctime && ...
   script_err != -1 && script_info.ctime < cache_info.ctime
   load -binary cache.mat Nr_Namn PrisPerFlaska fyllighet_stravhet_fruktsyra_smaker beskrivning;
  return;
endif


%
% Kolla om det finns en chache
%

wh = waitbar(0);

[nr,Namn,PrisPerLiter,fyllighet,stravhet,fruktsyra,desc] = ...
 textread(filename, "%s\t%s\t%f\t%d\t%d\t%d\t%s", "headerLines", 1, "delimiter", "\t");

PrisPerFlaska = PrisPerLiter .* 0.75;

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

beskrivning = cell(length(desc), 1);
for i = 1:length(desc)
  row = sprintf("fyllighet %d, strävhet %d, fruktsyra %d, %s",...
    fyllighet(i), stravhet(i), fruktsyra(i), desc{i});
  beskrivning{i} = row;
endfor

save -binary cache.mat Nr_Namn PrisPerFlaska fyllighet_stravhet_fruktsyra_smaker beskrivning;
