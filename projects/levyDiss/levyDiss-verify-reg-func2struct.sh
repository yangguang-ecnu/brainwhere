#!/bin/sh

herSubj=$1
# edit this to get the correct subject output from afni_proc:
subj=${herSubj}.modernLags6

# gets output directory where these images are stored:
source $bwDir/projects/levyDiss/levyDiss_environment.sh

fslview \
${outDir}/${subj}.results/MNI/${subj}_t1.nii.gz -l Green \
${outDir}/${subj}.results/MNI/${subj}_t1_brain.nii.gz -t 0.0 \
${outDir}/${subj}.results/MNI/${subj}_epi_averaged_func2struct.nii.gz -t 0.7 &
