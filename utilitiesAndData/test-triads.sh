#!/bin/sh

# first argument after command is the resp file for which user wants to perform calcualtions:
respOrig=$1

# create a temporary directory in the current directory, copy the resp file to it, and cd there:
mkdir tempTriads
tempDir="tempTriads"
cp $respOrig ${tempDir}/
cd $tempDir


# loop for the first 9 TRs of an 11-TR resp file: calculate the signed and unsigned mean of every triad of consecutive TRs

for startingVol in 0 1 2 3 4 5 6 7 8; do
	
	# establish which three TRs of the resp file belong to the triad:
	TRfirst=$startingVol
	TRthird=$(($startingVol + 2))

	#calculate signed mean of the triad:
	3dMean \
		-prefix=triad0${startingVol}meanSigned \
		respOrig"[${TRfirst}..${TRthird}]"

	# calculate unsigned mean of the triad:
	3dcalc \
		-a triad0${startingVol}meanSigned.HEAD \
		-expr 'abs(a)' \
		-prefix triad0${startingVol}meanUnsigned
done

# calculate the final signed max triad average across 9 triads, for example:
# a through i are teh 9 unsigned images,
# j through r are the corresponding singed images
3dcalc \
	-a triad00meanUnsigned \
	-b triad01meanUnsigned \
	-c triad02meanUnsigned \
	-d triad03meanUnsigned \
	-e triad04meanUnsigned \
	-f triad05meanUnsigned \
	-g triad06meanUnsigned \
	-h triad07meanUnsigned \
	-i triad08meanUnsigned \
	-j triad00meanSigned \
	-k triad01meanSigned \
	-l triad02meanSigned \
	-m triad03meanSigned \
	-n triad04meanSigned \
	-o triad05meanSigned \
	-p triad06meanSigned \
	-q triad07meanSigned \
	-r triad08meanSigned \
	-expr 'pairmax(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r)' \
	-prefix maximumAbsTriadMean_signed

3dcalc \
	-a triad00meanUnsigned \
	-b triad01meanUnsigned \
	-c triad02meanUnsigned \
	-d triad03meanUnsigned \
	-e triad04meanUnsigned \
	-f triad05meanUnsigned \
	-g triad06meanUnsigned \
	-h triad07meanUnsigned \
	-i triad08meanUnsigned \
	-j triad00meanUnsigned \ 
	-k triad01meanUnsigned \
	-l triad02meanUnsigned \
	-m triad03meanUnsigned \
	-n triad04meanUnsigned \
	-o triad05meanUnsigned \
	-p triad06meanUnsigned \
	-q triad07meanUnsigned \
	-r triad08meanUnsigned \
	-expr 'pairmax(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r)' \
	-prefix maximumAbsTriadMean_unsigned
	
