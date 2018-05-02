
global Jplotting;
Jplotting = [];

[nr, pris, fysufrsm, beskrivning, forpackning] = read_systembolaget();

figure(1, "name", "Systembolaget");
clf

subplot (2, 3, 1)
y = pris;
x = fysufrsm(:, 1);
plot(x, y, "x.");
title("Fyllighet och pris");
xlabel("Fyllighet");
ylabel("Pris");

subplot (2, 3, 2)
y = pris;
x = fysufrsm(:, 2);
plot(x, y, "x.");
title("Strävhet och pris");
xlabel("Strävhet");
ylabel("Pris");

subplot (2, 3, 3)
y = pris;
x = fysufrsm(:, 3);
plot(x, y, "x.");
title("Fruktsyra och pris");
xlabel("Fruktsyra");
ylabel("Pris");

subplot (2, 3, 4)

trainlength = length(nr);

y_train = pris(1:trainlength, :);
X_train = [ones(length(fysufrsm), 1) double(fysufrsm)](1:trainlength, :);
initial_theta = zeros(length(X_train(1, :)), 1);
options = optimset('GradObj', 'on', 'MaxIter', 200);
lambda = 1;
pause(0.1); % Show graphs


[theta, J, exit_flag] = ...
	fminunc(@(t)(linearRegCostFunction(X_train, y_train, t, lambda)), initial_theta, options);

%
% Kör igenom allt data och räkna ut hur vilket pris varje vin är värt
%
X = X_train;
estimated = X * theta;

%
% Skriv ut 10 feldiffade varor
%
diffs = y - estimated;
percent_diff = (estimated ./ y) - 1;

output = [percent_diff y estimated diffs];
output_precision(2);

[output_sort ind] = sortrows(output);
printf("10 viner som har störst diff:\n");
for i = 1:10
  v = int32(ind(i));
  printf("Vin %s (%s), Kostar %.0f kr, Smakvärderad till %.0f kr\n", ...
    nr{v, 1}, nr{v, 2}, output(v, 2), output(v, 3))
endfor


%
% Plotta faktiskt pris mot beräknat pris
%
figure(2)
y = pris;
x = estimated;
plot(x, y, "x.");
title("Systembolagets vinpriser");
xlabel("Datorns uppskattade smakpris");
ylabel("Faktiskt pris");
print -dpng figure.png

%
% Spara allt data i html-format
%
fo = fopen("output.html", "w");
fheader = fopen("header.html", "r");
fwrite(fo, fread(fheader));
fclose(fheader);

fwrite(fo, "<tr valign=top> \
<th>Förpackning</th>\n\
<th>Nr</th>\n\
<th>Namn</th>\n\
<th>Pris/flaska</th>\n\
<th>Uppskattat värde</th>\n\
<th>Prisökning</th>\n\
<th>Beskrivning</th>\n\
</tr>");

for i = 1:length(nr)
  fwrite(fo, "<tr valign=top>");
  fprintf(fo, "<td>%s</td>\n", forpackning{i});
  fprintf(fo, "<td><a href='https://www.systembolaget.se/%s' target='_blank'>%s</a></td>\n", ...
          nr{i, 1}, nr{i, 1});
  fprintf(fo, "<td>%s</td>\n", nr{i, 2});
  fprintf(fo, "<td>%d</td>\n", int32(pris(i)));
  fprintf(fo, "<td>%d</td>\n", int32(estimated(i)));
  fprintf(fo, "<td>%d%%</td>\n", int32(percent_diff(i)*100));
  fprintf(fo, "<td>%s</td>\n", beskrivning{i});
  fwrite(fo, "</tr>\n");
endfor
fwrite(fo, "</table></html>\n");
fclose(fo);

printf("Sparat resultat i filen 'output.html'\n");
