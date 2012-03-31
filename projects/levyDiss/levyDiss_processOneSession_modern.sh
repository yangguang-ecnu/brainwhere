#!/bin/sh
# levyDiss_processOneSession_modern.sh

clear

# get variables from environment setup script: $studyDir $outDir $subjsYoung $subjsOld $subjs
source ${bwDir}/projects/levyDiss/levyDiss_environment.sh

herSubj="$1"
###### test loop for all subjects:
# for herSubj in `echo ${subjs}`; do
subj="${herSubj}.modern0to12s"

epis="${studyDir}/${herSubj}/${herSubj}.epi?.SC?.treg+orig.HEAD"
anat="${studyDir}/${herSubj}/${herSubj}.T1_1.trega+orig.HEAD"
# our input files (tregs) already have the disdaq's removed
# disdacqs=0
#legacyMaxlag=9
#legacyPolort=0
legacyStimFileA="/data/birc/RESEARCH/STN/SUBCORT_DISS_2009/SC/AssortedScripts/stimFiles10-14-11/${herSubj}.A.CorrEx3.Uncat.1D"
legacyStimFileB="/data/birc/RESEARCH/STN/SUBCORT_DISS_2009/SC/AssortedScripts/stimFiles10-14-11/${herSubj}.B.CorrEx3.Uncat.1D"


# echo 'DEBUG'
# ls -al ${errts}

cd ${outDir}
#echo "pwd and contents:"
#pwd
#ls -l
echo ""
ls -ld ${outDir}/*${subj}*
echo ""
#echo "continue by starting with removal of ${outDir}/*${subj}* (ctrl-c to cancel) ?"
#echo ""
#read

echo ""
rm -fr ${outDir}/*${subj}*
rm -f ${outDir}/${subj}.wholeHead*
3dcopy ${anat} ${outDir}/${subj}.wholeHead

########################################################################
# run afni_proc.py to generate script proc.${subj}, and run proc.${subj}:

# 12 s :  -regress_basis 'TENT(0,12,7)' \
afni_proc.py \
-subj_id ${subj} \
-out_dir ${outDir}/${subj}.results \
-dsets ${epis} \
-copy_anat ${anat} \
-copy_files ${outDir}/${subj}.wholeHead* \
-blocks align volreg blur mask scale regress \
-align_epi_strip_method 3dAutomask \
-volreg_align_to first \
-volreg_interp -Fourier \
-blur_size 5 \
-regress_stim_files ${legacyStimFileA} ${legacyStimFileB} \
-regress_stim_labels TaskA TaskB \
-regress_basis 'TENT(0,12,7)' \
-regress_censor_motion 1.0 \
-regress_censor_outliers 0.1 \
-regress_apply_mot_types demean \
-regress_opts_3dD -rout -jobs 4 \
-regress_errts_prefix errts \
-regress_reml_exec

#	-gltsym 'SYM: +TaskB -TaskA' \
#	-glt_label 1 TaskA_vs_TaskB \
#echo ""
#echo "Proceed with exection of proc.${subj}? (enter to continue, ctrl-c to quit)"
#read 

tcsh -xef proc.${subj} 2>&1 | tee output.proc.${subj}
rm -f ${outDir}/${subj}.wholeHead*

ls -l ${outDir}/${subj}.results
echo ""
echo "...afni_proc done"

########################################################################
# calculate area under the curve from the TaskA and TaskB IRFs:

echo ""
echo "calculate AUC..."
irespTaskA=${outDir}/${subj}.results/iresp_TaskA.${subj}*HEAD
irespTaskB=${outDir}/${subj}.results/iresp_TaskB.${subj}*HEAD
ls -l ${irespTaskA} ${irespTaskB}
aucPrefixTaskA=${outDir}/${subj}.results/aucTaskA.${subj}
aucPrefixTaskB=${outDir}/${subj}.results/aucTaskB.${subj}
rm -f ${aucPrefixTaskA}*
rm -f ${aucPrefixTaskB}*
3dcalc -prefix ${aucPrefixTaskA} \
        -a0 ${irespTaskA} \
        -b1 ${irespTaskA} \
        -c2 ${irespTaskA} \
        -d3 ${irespTaskA} \
        -e4 ${irespTaskA} \
        -f5 ${irespTaskA} \
        -expr a+b+c+d+e+f

3dcalc -prefix ${aucPrefixTaskB} \
        -a0 ${irespTaskB} \
        -b1 ${irespTaskB} \
        -c2 ${irespTaskB} \
        -d3 ${irespTaskB} \
        -e4 ${irespTaskB} \
        -f5 ${irespTaskB} \
        -expr a+b+c+d+e+f

echo ""
ls -l ${aucPrefixTaskA}*
ls -l ${aucPrefixTaskB}*
echo ""
echo "...done calculating AUC."


########################################################################
# now bring interesting images into MNI space for later group comparisons:

# DEBUG: testing file locations and names before executing:
#	echo "${subj}"
#	ls -l ${outDir}/${subj}.results/${herSubj}.T1_1.trega+orig.HEAD
#	ls -l ${outDir}/${subj}.results/pb00.${subj}.r01.tcat+orig.HEAD 
#	ls -l ${outDir}/${subj}.results/stats.${subj}+orig.HEAD
#	ls -l ${outDir}/${subj}.results/stats.${subj}_REML+orig.HEAD
#	ls -l ${outDir}/${subj}.results/aucTaskA.${subj}+orig.HEAD
#	ls -l ${outDir}/${subj}.results/aucTaskB.${subj}+orig.HEAD
#	ls -l ${outDir}/${subj}.results/iresp_TaskA.${subj}+orig.HEAD
#	ls -l ${outDir}/${subj}.results/iresp_TaskB.${subj}+orig.HEAD

mkdir ${outDir}/${subj}.results/MNI
${bwDir}/registerTo1mmMNI152.sh \
-s ${subj} \
-t ${outDir}/${subj}.results/${herSubj}.T1_1.trega+orig.HEAD \
-o ${outDir}/${subj}.results/MNI \
-e ${outDir}/${subj}.results/pb00.${subj}.r01.tcat+orig.HEAD \
-b ${outDir}/${subj}.results/stats.${subj}+orig.HEAD \
-b ${outDir}/${subj}.results/stats.${subj}_REML+orig.HEAD \
-b ${outDir}/${subj}.results/aucTaskA.${subj}+orig.HEAD \
-b ${outDir}/${subj}.results/aucTaskB.${subj}+orig.HEAD \
-b ${outDir}/${subj}.results/iresp_TaskA.${subj}+orig.HEAD \
-b ${outDir}/${subj}.results/iresp_TaskB.${subj}+orig.HEAD


##### end of test loop for all subjects
# done
##### end of test loop for all subjects
