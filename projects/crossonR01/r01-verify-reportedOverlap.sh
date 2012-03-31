#!/bin/sh

blind=$1
session=$2

source $bwDir/projects/crossonR01/r01-environment.sh

fslview \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_warped.nii.gz -t .7 \
${FSLDIR}/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-1mm.nii.gz -t .0 \
${bwDir}/utilitiesAndData/localization/1mmCrosson3roiVer3Only.nii.gz -l "MGH-Cortical" -t .5 \
${parentDir}/${blind}/pre/afnifiles/${blind}_pre_clust.12thresh.50ul_mask*.nii.gz \
${parentDir}/${blind}/post/afnifiles/${blind}_post_clust.12thresh.50ul_mask*.nii.gz -t .0 \
${parentDir}/${blind}/3mo/afnifiles/${blind}_3mo_clust.12thresh.50ul_mask*.nii.gz -t .0 &
	
#gedit /home/stowler/toScreen-r01clusterReports/${blind}_${session}*clust.16thresh.50ul_report*.txt &
#gedit ${parentDir}/${blind}/${session}/afnifiles/${blind}*${session}*report*txt &

# afni \
# /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/${session}/afnifiles/${blind}_${session}*stim.resp.nii.gz \
# /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/${session}/afnifiles/${blind}_${session}*allresp.resp.nii.gz \
# /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/${session}/afnifiles/${blind}_${session}*stim.buck.nii.gz \
# /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/${session}/afnifiles/${blind}_${session}*allresp.buck.nii.gz &
afni \
${parentDir}/${blind}/${session}/afnifiles/*stim.buck.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/*allresp.buck.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/*resp.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/*t1_orig.nii.gz

