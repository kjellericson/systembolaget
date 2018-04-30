
global Jplotting;
Jplotting = [];

[nr, pris, smak] = read_systembolaget();

figure(1, "name", "Systembolaget");
clf

subplot (2, 2, 1)
y = pris;
x = smak(:, 1);
plot(x, y, "x.");
title("Fyllighet och pris");
xlabel("Fyllighet");
ylabel("Pris");

subplot (2, 2, 2)
y = pris;
x = smak(:, 2);
plot(x, y, "x.");
title("Strävhet och pris");
xlabel("Strävhet");
ylabel("Pris");

subplot (2, 2, 3)
y = pris;
x = smak(:, 3);
plot(x, y, "x.");
title("Fruktsyra och pris");
xlabel("Fruktsyra");
ylabel("Pris");

subplot (2, 2, 4)

trainlength = length(nr);

y_train = pris(1:trainlength, :);
X_train = [ones(length(smak), 1) double(smak)](1:trainlength, :);
initial_theta = zeros(length(X_train(1, :)), 1);
options = optimset('GradObj', 'on', 'MaxIter', 200);
lambda = 1;
pause(0.1); % Show graphs


[theta, J, exit_flag] = ...
	fminunc(@(t)(linearRegCostFunction(X_train, y_train, t, lambda)), initial_theta, options);

  
X = X_train;
estimated = X * theta;
diffs = y - estimated;
percent_diff = y ./ estimated;

output = [percent_diff y estimated diffs];
output_precision(2);

[output_sort ind] = sortrows(output);
for i = 1:10
  v = int32(ind(i));
  printf("Vin %s (%s), Kostar %.0f kr, Smakvärderad till %.0f kr\n", ...
    nr{v, 1}, nr{v, 2}, output(v, 2), output(v, 3))
endfor
