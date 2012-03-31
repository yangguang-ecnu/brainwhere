#!/bin/sh

herSubj=$1
# edit this to get the correct subject output from afni_proc:
subj=${herSubj}.modernLags6

# gets output directory where these images are stored:
source $bwDir/projects/levyDiss/levyDiss_environment.sh

fslview \
$FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz -l Green \
${outDir}/${subj}.results/MNI/${subj}_t1_warped.nii.gz -l Yellow -t 0.8 \
${outDir}/${subj}.results/MNI/${subj}_t1_brain_warped.nii.gz -t 0.6 &
