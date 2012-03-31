#!/bin/sh

# first get the blind numbers and parent dir:
source $bwDir/projects/crossonR01/r01-environment.sh
clear

echo ""
echo "verify whether the final plots match the cluster report laterality indicies:"
echo "(ensuring that nothing was amiss in extraction of data from cluster reports"
echo "or generation of plots from those extracted data)"
echo ""
for blind in `echo ${intentionBlinds} ${controlBlinds}`; do
     for session in pre post 3mo; do
      echo "${blind} ${session}"
      echo "(fields below are roi, ulTotal, ulLeft, ulRight, lateralityIndex)"
      grep CROSSON \
         ${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer2Only.txt \
         | awk '{print $2, $3, $5, $6, $7}' | column -t
      echo ""
      echo "(return to continue to next session, or CTRL-C to quit)"
      read
     done
done
