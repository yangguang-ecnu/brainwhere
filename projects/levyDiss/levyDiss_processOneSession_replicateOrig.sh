#!/bin/sh

clear 

# get variables from environment setup script: $studyDir $outDir $subjsYoung $subjsOld $subjs
source ${bwDir}/projects/levyDiss/levyDiss_environment.sh

herSubj="$1"
subj="${herSubj}.TESTPARALLEL"
##### test loop for all subjects:
##### for subj in `echo ${subjs}`; do

epis="${studyDir}/${herSubj}/${herSubj}.epi?.SC?.treg+orig.HEAD"
anat="${studyDir}/${herSubj}/${herSubj}.T1_1.trega+orig.HEAD"
# our input files (tregs) already have the disdaq's removed
# disdacqs=0
#legacyMaxlag=9
#legacyPolort=0
legacyStimFileA="/data/birc/RESEARCH/STN/SUBCORT_DISS_2009/SC/AssortedScripts/StimFiles10-5-11/${herSubj}.A.Corr.Uncat.1D"
legacyStimFileB="/data/birc/RESEARCH/STN/SUBCORT_DISS_2009/SC/AssortedScripts/StimFiles10-5-11/${herSubj}.B.Corr.Uncat.1D"


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

# 5 lags: -regress_basis 'TENT(6,14,5)' \
# 6 lags: -regress_basis 'TENT(4,14,6)' \
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
-regress_basis 'TENT(6,14,5)' \
-regress_opts_3dD -rout -jobs 8 \
	-gltsym 'SYM: +TaskB -TaskA' \
	-glt_label 1 TaskA_vs_TaskB \
-regress_errts_prefix errts 
#-regress_reml_exec

#echo ""
#echo "Proceed with exection of proc.${subj}? (enter to continue, ctrl-c to quit)"
#read 

tcsh -xef proc.${subj} 2>&1 | tee output.proc.${subj}
rm -f ${outDir}/${subj}.wholeHead*

ls -l ${outDir}/${subj}.results
echo ""
echo "...afni_proc done"

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
	-expr a+b+c+d+e

3dcalc -prefix ${aucPrefixTaskB} \
	-a0 ${irespTaskB} \
	-b1 ${irespTaskB} \
	-c2 ${irespTaskB} \
	-d3 ${irespTaskB} \
	-e4 ${irespTaskB} \
	-expr a+b+c+d+e

echo ""
ls -l ${aucPrefixTaskA}*
ls -l ${aucPrefixTaskB}*
echo ""
echo "...done calculating AUC."

#### then just have larger script that says cats ${outDir}/${subj}/corrPearson_PFC_RSP_cleaned.txt for everyone and sends to csv for import into excel

##### end of test loop for all subjects
##### done
##### end of test loop for all subjects
