#!/bin/sh

# get study-related variables, including blind numbers:
source ${bwDir}/projects/crossonR01/r01-environment.sh

# print one line of column headers for import to existing R scripts
echo "participant,group,session,roi,ulLeft,ulRight"

# this triple loop extracts left and right ul volumes for each blindXsessionXroi combo:
for blind in `echo ${intentionBlinds} ${controlBlinds}`; do
   for session in pre post 3mo; do
      for roi in CROSSONlateralFrontalROI CROSSONPerisylvian CROSSONmedialFrontal; do
         clusterReportFile="${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer2Only.txt"
         ulLeft=`grep ^.....${roi} ${clusterReportFile} | awk '{print $5}'`
         ulRight=`grep ^.....${roi} ${clusterReportFile} | awk '{print $6}'`
         # assign group label for line, allowing that user accidentally assigned blind to multiple groups
         group=""
         if grep -q ${blind} <<<${intentionBlinds}; then group="intention"; fi
         if grep -q ${blind} <<<${controlBlinds}; then group="${group}control"; fi
         if [ -z ${group} ]; then group="other"; fi
         echo "${blind},${group},${session},${roi},${ulLeft},${ulRight}" 
      done
   done
done

