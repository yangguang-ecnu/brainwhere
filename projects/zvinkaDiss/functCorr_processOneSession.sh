#!/bin/sh

clear 

# get variables from environment setup script: $studyDir $outDir $subjsYoung $subjsSedent $subjsActive
source ${bwDir}/projects/zvinkaDiss/zz-environment.sh

subj="$1"
###### test loop for all subjects:
###### for subj in `echo ${subjsYoung} ${subjsSedent} ${subjsActive}`; do

# echo "1 -40 16" | 3dUndump -prefix mask-PFC-sphere8mmRadius -master s02.3danat_al_keep+tlrc.HEAD -xyz -srad 8 -
# echo "-1 50 26" | 3dUndump -prefix mask-RSP-sphere8mmRadius -master s02.3danat_al_keep+tlrc.HEAD -xyz -srad 8 -
maskPFC="${bwDir}/utilitiesAndData/localization/spheres/mask-PFC-sphere8mmRadius+tlrc.HEAD"
maskRSP="${bwDir}/utilitiesAndData/localization/spheres/mask-RSP-sphere8mmRadius+tlrc.HEAD"
acqfile="${studyDir}/SUBJECTS/AF_${subj}/afnifiles_ZZ/${subj}.cognewALL.5blur.norm.signal.change+orig.HEAD"
anat="${studyDir}/SUBJECTS/AF_${subj}/afnifiles_ZZ/${subj}.3danat+orig.HEAD"
disdacqs=0
legacyMaxlag=9
legacyPolort=0
legacyStimFile="/home/stowler/temp/ZZ_CogALL_stim.1D"


# echo 'DEBUG'
# ls -al ${errts}

cd /data/birc/RESEARCH/AEROBIC_FITNESS/stowler_functCorr
echo "pwd and contents:"
pwd
ls -l
echo ""
ls -ld ${outDir}/*${subj}*
# echo "continue by starting with removal of ${outDir}/*${subj}* (ctrl-c to cancel) ?"
# echo ""
# read

rm -fr ${outDir}/*${subj}*
3dBandpass -prefix ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass 0.009 0.08 ${acqfile}
ls -lh ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass*
echo ""
rm -f ${outDir}/${subj}.wholeHead*
3dcopy ${anat} ${outDir}/${subj}.wholeHead

# -tlrc_anat \
afni_proc.py \
-out_dir ${outDir}/${subj}.results \
-subj_id ${subj} \
-dsets ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass+orig.HEAD \
-copy_anat ${anat} \
-copy_files ${outDir}/${subj}.wholeHead* \
-blocks align tlrc volreg mask scale regress \
-tcat_remove_first_trs ${disdacqs} \
-volreg_align_to first \
-volreg_interp -Fourier \
-volreg_tlrc_warp \
-align_epi_strip_method 3dAutomask \
-align_opts_aea -child_anat ${subj}.wholeHead+orig.HEAD \
-regress_stim_files ${legacyStimFile} \
-regress_basis 'TENT(0,18,10)' \
-regress_apply_mot_types demean \
-regress_opts_3dD -rout -nocout -jobs 8 \
-regress_errts_prefix errts

# resulting full_mask files are 1/0 reveresed
# ....still reveresed if I starat with non-bandpass filtered? yup
# ....still reveresed if I  add blur block 1mm?  yup



# maybe add -tlrc_rmode RMODE "Please see '@auto_tlrc -help' for more information."
# Please see '@auto_tlrc -help' for more information.d

# echo ""
# echo "Proceed with exection of proc.${subj}? (enter to continue, ctrl-c to quit)"
# read 

tcsh -xef proc.${subj} 2>&1 | tee output.proc.${subj}
rm -f ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass*
rm -f ${outDir}/${subj}.wholeHead.*

ls -l ${outDir}/${subj}.results
echo ""
echo "...afni_proc done"

echo ""
echo "...now upsampling to 1x1x1mm and extracting average timecourses from masked areass...(takes a few mintues and aboug 10 GB RAM)..."
echo ""

# upsample errts into 1x1x1 mm space for alignment with spherical ROI masks:
3dresample -rmode Cu -master ${maskPFC} -prefix ${outDir}/${subj}.results/errts.${subj}.1mm -inset ${outDir}/${subj}.results/errts.${subj}+tlrc.HEAD
# extract average time course per ROI:
3dmaskave -quiet -mask ${maskPFC} ${outDir}/${subj}.results/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/${subj}.results/avgErrtsPFC.1D
3dmaskave -quiet -mask ${maskRSP} ${outDir}/${subj}.results/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/${subj}.results/avgErrtsRSP.1D
rm -f ${outDir}/${subj}.results/errts.${subj}.1mm*

echo ""
head ${outDir}/${subj}.results/avgErrts*.1D

1dCorrelate -Pearson ${outDir}/${subj}.results/avgErrtsPFC.1D ${outDir}/${subj}.results/avgErrtsRSP.1D > ${outDir}/${subj}.results/corrPearson_PFC_RSP.txt
echo -n "${subj}," > ${outDir}/${subj}.results/corrPearson_PFC_RSP_cleaned.csv
cat ${outDir}/${subj}.results/corrPearson_PFC_RSP.txt | tail -1 | awk '{print $3}' >> ${outDir}/${subj}.results/corrPearson_PFC_RSP_cleaned.csv

echo ""
echo "Correlation information written to files:"
ls -l  ${outDir}/${subj}.results/corrPearson_PFC_RSP*
echo ""
echo "Pearson product moment correlation between ROIs is:" 
cat ${outDir}/${subj}.results/corrPearson_PFC_RSP_cleaned.csv


#### then just have larger script that says cats ${outDir}/${subj}/corrPearson_PFC_RSP_cleaned.txt for everyone and sends to csv for import into excel

##### end of test loop for all subjects
##### done
##### end of test loop for all subjects
