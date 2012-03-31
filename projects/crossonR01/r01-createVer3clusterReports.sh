#!/bin/sh

# get study-related variables, including blind numbers:
source ${bwDir}/projects/crossonR01/r01-environment.sh

# temp for parallel execution:
blind=$1

# this triple loop extracts left and right ul volumes for each blindXsessionXroi combo:
#for blind in `echo ${intentionBlinds} ${controlBlinds}`; do
   for session in pre post 3mo; do
	rm -f ${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer3Only.txt
	${bwDir}/clusterReporter.sh \
	-m ${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_maskBW.nii.gz \
	-o ${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer3Only.txt \
	-a 1mmCrosson3roiVer3Only
   done
#done

