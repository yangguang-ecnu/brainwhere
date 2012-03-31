#!/bin/sh
#
# A short script that opens AFNI to inspect IRFs from the R01 project.
#
# Execute this inspection script like this (no quotes, no squre brackets):
# 	"sh ${bwDir}/projects/crossonR01/r01-verify-IRF.sh [blind] [session]" 
#
# for example, to inspect INT2_s04's pre session, issue this command:
# 	sh ${bwDir}/projects/crossonR01/r01-verify-IRF.sh INT2_s04 pre
#
# This script just opens AFNI and loads the following volumes for inspection of
# underlying IRFs. Recall that final rsq data were created by taking the max
# rsq from the higher of the allresp and stim deconvolutions. This means that
# any given voxel in the final output has an rsq that comes from one tof two
# deconvolutions, and you don't know which, so to view the estimated IRF
# associated with the rsq value you will need to look at BOTH *stim.resp.nii.gz
# and *.allresp.resp.nii.gz 


# ----------------------------------
# Useful underlays for inspection:
# ----------------------------------

# the estimated IRF timeseries from stim-based deconvolution:
# 	${blind}_${session}_stim.resp.nii.gz
#	(e.g., INT2_s04_pre_stim.resp.nii.gz)

# the estimated IRF timeseries from allresp-based deconvolution:
#	${blind}_${session}_allresp.resp.nii.gz
#	(e.g., INT2_s04_pre_allresp.resp.nii.gz)

# the native-space 3Dt1: 
#	${blind}_${session}_t1_brain.nii.gz
#	(e.g., INT2_s04_pre_t1_brain.nii.gz) 


# ----------------------------------
# Useful overlays for inspection:
# ----------------------------------

# the rsq map used in calculation of suprathresholded volumes
# (non-zero rsq's surivived gamma-variate-shape-filtering, and
# represent the max from allresp and stim deconvolutions)
#	${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz
#	(e.g., INT2_s04_pre_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz)

blind=$1
session=$2
source ${bwDir}/projects/crossonR01/r01-environment.sh

clear 

echo "#########################################################################"
echo "Attempting to open afni to display the following overlay and underlay"
echo "with other underlays available (just click AFNI's Underlay button): "
echo "#########################################################################"
echo ""
echo ""

echo "1) The overlay as final thresholded R01 Rsq values:"
echo ""
echo "${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz"
echo ""
echo ""

echo "2) The underlay as the stim-based resp file:"
echo ""
echo "${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_stim.resp.nii.gz"
echo ""
echo ""

echo "3) Optional underlay available behind AFNI "Underlay" button: all-resp resp file:"
echo ""
echo "${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_allresp.resp.nii.gz"
echo ""
echo ""

echo "4) Optional underlay available behind AFNI "Underlay" button: T1 anatomic:"
echo ""
echo "${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz"
echo ""
echo ""

afni -q \
-com 'OPEN_WINDOW A geom=+5+24' \
-com 'OPEN_PANEL A.Define_Overlay' \
-com 'SET_THRESHOLD A.0999 0' \
-com 'SET_PBAR_ALL A.+99 1.000000 Spectrum:red_to_blue' \
-com 'SET_FUNC_VISIBLE A.+' \
-com 'SET_FUNC_RESAM A.NN.NN' \
-com 'SET_FUNC_RANGE A.1.000000' \
-com "SET_UNDERLAY A.${blind}_${session}_stim.resp.nii.gz 0" \
-com "SET_OVERLAY A.${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz 0 0" \
-com 'OPEN_WINDOW A.axialimage geom=262x392+299+417 ifrac=0.8 opacity=9' \
-com 'OPEN_WINDOW A.sagittalimage geom=346x346+299+837 ifrac=0.8 opacity=9' \
-com 'OPEN_WINDOW A.coronalimage geom=287x431+4+418 ifrac=0.8 opacity=9' \
-com 'OPEN_WINDOW A.axialgraph geom=420x380+569+418 matrix=3' \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_stim.resp.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_allresp.resp.nii.gz \
${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz &
