#!/bin/sh

clear 

# get variables from environment setup script: $studyDir $outDir $subjsYoung $subjsSedent $subjsActive
source ${bwDir}/projects/harold/harold-environment.sh

subj="$1"
ver=stowler
lp=
###### test loop for all subjects:
###### for subj in `echo ${subjsYoung} ${subjsSedent} ${subjsActive}`; do

# echo "1 -40 16" | 3dUndump -prefix mask-PFC-sphere8mmRadius -master s02.3danat_al_keep+tlrc.HEAD -xyz -srad 8 -
# echo "-1 50 26" | 3dUndump -prefix mask-RSP-sphere8mmRadius -master s02.3danat_al_keep+tlrc.HEAD -xyz -srad 8 -
maskPFC="${bwDir}/utilitiesAndData/localization/spheres/mask-PFC-sphere8mmRadius+tlrc.HEAD"
maskRSP="${bwDir}/utilitiesAndData/localization/spheres/mask-RSP-sphere8mmRadius+tlrc.HEAD"
#acqfile="${studyDir}/SUBJECTS/AF_${subj}/afnifiles_ZZ/${subj}.cognewALL.5blur.norm.signal.change+orig.HEAD"
#anat="${studyDir}/SUBJECTS/AF_${subj}/afnifiles_ZZ/${subj}.3danat+orig.HEAD"
anat="${studyDir}/SUBJECTS/${subj}/afnifiles/${subj}.3danat+orig.HEAD"
#disdacqs=0
#legacyMaxlag=9
#legacyPolort=0
#legacyStimFile="/home/stowler/temp/ZZ_CogALL_stim.1D"


# echo 'DEBUG'
# ls -al ${errts}

outDir=${studyDir}/SUBJECTS/${subj}/afnifiles
cd ${outDir}
ls
echo "pwd and contents:"
pwd
ls -l
echo ""

#read
#ls -ld ${outDir}/*${subj}*
# echo "continue by starting with removal of ${outDir}/*${subj}* (ctrl-c to cancel) ?"
# echo ""
# read

#rm -fr ${outDir}/*${subj}*
#3dBandpass -prefix ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass 0.009 0.08 ${acqfile}
#ls -lh ${outDir}/${subj}.cognewALL.5blur.norm.signal.change.bandpass*
echo ""

#rm -f ${subj}.block_nm_11_${ver}.resp*
#rm -f ${subj}.block_nm_11_${ver}.buck*
#rm -f ${subj}.block_nm_11_${ver}.errts*
rm -f errts.${subj}.1mm*
rm -f *${ver}*
rm -f ${subj}.xmat.1D
rm -f ${subj}.REML_cmd
rm -f avgErrts*.1D
rm -f corrPearson*

3dDeconvolve \
-input ${subj}.block_sm_norm+orig.HEAD \
-jobs 4 \
-polort 0 \
-num_stimts 1 \
-stim_file 1 ${subj}block_concat.1D \
-stim_minlag 1 0 \
-stim_maxlag 1 11 \
-iresp 1 ${subj}.block_nm_11_${ver}.resp \
-rout -nocout -bucket ${subj}.block_nm_11_${ver}.buck \
-errts ${subj}.block_nm_11_${ver}.errts

#echo "PAUSE"
#read


echo ""
echo "...now thresholding errts by rsq"
echo ""

rsqthresh=0.24

# create binary mask from thresholded rsq:
3dmerge \
-2thresh -${rsqthresh} ${rsqthresh} \
-1dindex 0 -1tindex 0 \
-prefix ${outDir}/rsq${rsqthresh}.${subj}_${ver} \
${subj}.block_nm_11_${ver}.buck+orig.HEAD



echo ""
echo "...now upsampling to 1x1x1mm and extracting average timecourses from masked areass...(takes a few mintues and aboug 10 GB RAM)..."
echo ""

# upsample errts into 1x1x1 mm space for alignment with spherical ROI masks:
#3dresample -rmode Cu -master ${maskPFC} -prefix ${outDir}/errts.${subj}.1mm -inset ${outDir}/${subj}.results/errts.${subj}+tlrc.HEAD
3dresample -rmode Cu -master ${maskPFC} -prefix ${outDir}/errts.${subj}.1mm -inset ${outDir}/${subj}.block_nm_11_${ver}.errts+orig.HEAD
3dresample -rmode Cu -master ${maskPFC} -prefix ${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm -inset ${outDir}/rsq${rsqthresh}.${subj}_${ver}+orig.HEAD

# multiply thresh mask by apriori anatomical masks to get mask that will be used in following 3dmaskae 3dresample and 3dmaskave:
3dcalc -prefix ${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm_maskPFC -a ${maskPFC} -b ${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm+tlrc.HEAD -expr 'a*b'
3dcalc -prefix ${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm_maskRSP -a ${maskRSP} -b ${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm+tlrc.HEAD -expr 'a*b'


# assign this new mask to the current $maskPFC and $maskRSP variables:
maskPFC="${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm_maskPFC+tlrc.HEAD"
maskRSP="${outDir}/rsq${rsqthresh}.${subj}_${ver}.1mm_maskRSP+tlrc.HEAD"

# extract average time course per ROI:
#3dmaskave -quiet -mask ${maskPFC} ${outDir}/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/${subj}.results/avgErrtsPFC.1D
#3dmaskave -quiet -mask ${maskRSP} ${outDir}/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/${subj}.results/avgErrtsRSP.1D
3dmaskave -quiet -mask ${maskPFC} ${outDir}/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/avgErrtsPFC.1D
3dmaskave -quiet -mask ${maskRSP} ${outDir}/errts.${subj}.1mm+tlrc.HEAD >> ${outDir}/avgErrtsRSP.1D
#rm -f ${outDir}/errts.${subj}.1mm*

echo ""
head ${outDir}/avgErrts*.1D

1dCorrelate -Pearson ${outDir}/avgErrtsPFC.1D ${outDir}/avgErrtsRSP.1D > ${outDir}/corrPearson_PFC_RSP.txt
echo -n "${subj}," > ${outDir}/corrPearson_PFC_RSP_cleaned.csv
cat ${outDir}/corrPearson_PFC_RSP.txt | tail -1 | awk '{print $3}' >> ${outDir}/corrPearson_PFC_RSP_cleaned.csv

echo ""
echo "Correlation information written to files:"
ls -l  ${outDir}/corrPearson_PFC_RSP*
echo ""
echo "Pearson product moment correlation between ROIs is:" 
cat ${outDir}/corrPearson_PFC_RSP_cleaned.csv


#### then just have larger script that says cats ${outDir}/${subj}/corrPearson_PFC_RSP_cleaned.txt for everyone and sends to csv for import into excel

##### end of test loop for all subjects
##### done
##### end of test loop for all subjects
