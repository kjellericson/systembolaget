all:

step1-download:
	./download.pl

step2-extract:
	./extract_description.pl

step3-octave:
	octave systembolaget.m