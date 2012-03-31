#!/bin/sh

blind=$1
session=$2

source $bwDir/projects/crossonR01/r01-environment.sh

parentDir=/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniRefweight

fslview \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz -l Green \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz -t 0.0 \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_lesion.nii.gz -l White -t 0.0 \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged_func2struct.nii.gz &
