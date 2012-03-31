#!/bin/sh

blind=$1
session=$2

source ${bwDir}/projects/crossonR01/r01-environment.sh

fslview \
$FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz -l Green \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_warped.nii.gz -l Yellow -t 0.8 \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain_warped.nii.gz -t 0.6 \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_lesion_warped.nii.gz -l White -t 0.7 \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_maskBW.nii.gz -t 0.0 &
