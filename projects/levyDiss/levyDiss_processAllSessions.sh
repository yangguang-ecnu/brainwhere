#!/bin/sh
# $bwDir/projects/levyDiss/levyDiss_processAllSessions.sh
clear

# get variables from environment setup script: $studyDir $outDir $subjsYoung $subjsOld $subjs
source ${bwDir}/projects/levyDiss/levyDiss_environment.sh
startDateTime=`date +%Y%m%d%H%M%S`              # ...used in file and dir names

##################################################################
# use ppss to process all sessions using modern processing:
#	# DEBUG: test ppss first:
#	rm -f /tmp/testing_ppss.txt
#	echo "${subjs_column}" | ~/scripts/ppss -f - -c 'echo "$ITEM" >> /tmp/testing_ppss.txt '
#	ls -al /tmp/testing_ppss.txt
#	cat /tmp/testing_ppss.txt
rm -fr ppss_dir
echo -e "${subjs_column}" | ~/scripts/ppss -f - -c \
	'sh ${bwDir}/projects/levyDiss/levyDiss_processOneSession_modern.sh '
mv ppss_dir ${outDir}/ppss_dir.$startDateTime

