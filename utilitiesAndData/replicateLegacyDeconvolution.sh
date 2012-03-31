#!/bin/sh
# replicateLegacyDeconvolution.sh
#
# Use afni_proc.py to duplicate legacy 3dDeconvolve results,
# demonstrating that tent and stick functions are equivalent.

acqfiles="/data/birc/RESEARCH/AEROBIC_FITNESS/SUBJECTS/AF_s02/afnifiles_ZZ/*.trega+orig.HEAD"
anat="/data/birc/RESEARCH/AEROBIC_FITNESS/SUBJECTS/AF_s02/afnifiles_ZZ/s02.3danat+orig.HEAD"
disdacqs=0
legacyMaxlag=9
legacyPolort=0
legacyStimFile="/home/stowler/temp/ZZ_CogALL_stim.1D"
legacyMotionCorrectedEPI=""

# ...for deconvolution only (input: legacy preprocessed images)
# afni_proc.py \
# -subj_id deconOnly \
# -dsets ${legacyMotionCorrectedEPI} \
# -blocks regress \
# -outlier_count no \
# -regress_stim_files ${legacyStimFile} \
# -regress_basis 'TENT(0,18,10)' \
# -regress_no_motion \
# -regress_opts_3dD -nfirst ${legacyMaxlag} -rout -nocout -jobs 4 \
# -regress_polort ${legacyPolort}

# ...for minimal preprocessing and deconvolution (input: acquisition files)
# afni_proc.py \
# -subj_id minimalSession \
# -dsets ${acqfiles} \
# -blocks align volreg mask regress \
# -outlier_count no \
# -copy_anat ${anat} \
# -tcat_remove_first_trs ${disdacqs} \
# -volreg_align_to first \
# -volreg_interp -Fourier \
# -regress_stim_files ${legacyStimFile} \
# -regress_basis 'TENT(0,16,9)' \
# -regress_no_motion \
# -regress_opts_3dD  -CENSORTR 1:0..7 -rout -nocout -jobs 8

# default blocks: tshift volreg blur mask scale regress
#
# adding mask block shouldn't change anything....and it doesn't
# removing -outlier_count no shouldn't change anything...and it doesn't
# copying anatomy over shouodn't change anything...and it doesn't
#
# despike decreases overall Rsq values, and probably shouldn't be used unless trying to prep for tshift (so as not to smear spikes across time)

# scale shouldn't change anything...resutls in slightly higher Rsq mean and median, but fewer significant voxels, probably like th8 
# ...and if we combine with removal of CENSORTR?

# despike results in crappier overall values...maybe b/c reduced efficacy of registration? TEST THIS WITH MOTION PARMS.
# ...and when combined with scale: some stats improve, some stats don't
# ...and if we leave those two combined and get rid of CENSORTR: that doesn't really change things.

#-no_epi_review \


# -regress_reml_exec 

afni_proc.py \
-subj_id modernSessionTLRC \
-dsets ${acqfiles} \
-copy_anat ${anat} \
-tlrc_anat \
-blocks align volreg blur mask scale regress \
-tcat_remove_first_trs ${disdacqs} \
-volreg_align_to first \
-volreg_interp -Fourier \
-volreg_tlrc_warp \
-blur_size 5.0 \
-regress_stim_files ${legacyStimFile} \
-regress_basis 'TENT(0,18,10)' \
-regress_apply_mot_types demean \
-regress_censor_motion 1.0 \
-regress_censor_outliers 0.1 \
-regress_opts_3dD -rout -nocout -jobs 8 \
-regress_errts_prefix errts



# diagnostic plots:
# - Are stims correlated wtih motion? Plot stim times on motion_demean.1D, motion_derive.1D, motion_${subj}_enorm.1D, and motion_${subj}_censor.1D

# - Are stims correlated with outlier TRs? Plot stim times on outcount.rall.1D and outcount_${subj}_censor.1D

# - Are outlier TRs correlated wtih motion? Plot outcount.rall.1D and outcount_${subj}_censor.1D on motion_demean.1D, motion_derive.1D, motion_${subj}_enorm.1D, and motion_${subj}_censor.1D

# - Does our model fit look good as a time series? Plot stim times on fitts

# EXAMPLE PLOTS:
# -------------------
# plot six-regressor 1D file:
# 1dplot -volreg -dx [TR] -xlabel Time motion_demean.1D &


# OUTLIER INSPECTION:
# ========================
#
# automasked fractional outlier count:
#		outcount.rall.1D 
#
# ...which is a concat of per-run outcount_r??.1D
# ...which are each from from "3dToutcount -automask -fraction ..."

# censored TRs based on automasked outlier fraction per TR (? afni_proc.py -regress_censor_outlier ?):
#		outcount_${subj}_censor.1D
#
# ...which is a concat of rm.out.cen.r*.1D,
# ...which are each produced by "1deval -a outcount_r$run.1D -expr "1-step(a-0.1)" > rm.out.cen.r$run.1D"


# MOTION INSPECTION:
# ==========================
 
# raw 6-parameter motion from 3dvolreg -1Dfile:
# 		dfile.rall.1D
#
# ...which is concat of dfile.r??.1D

# demeaned 6-parameter motion regressors:
#		motion_demean.1D
#
# ...which is from "1d_tool.py -infile dfile.rall.1D ... -demean ..."

# derivatives of 6-parameter motion dregressors:
#		motion_deriv.1D
#
# ...which is from "1d_tool.py -infile dfile.rall.1D ... -derivative -demean ...."

# censored TRs based on motion, triggered by "afni_proc -regress_censor_motion [thresh]" 
#		motion_${subj}_enorm.1D 	(plot to find out why TRs were censored for motion)
#		motion_${subj}_censor.1D
#		motion_${subj}_CENSORTR.txt
# 
# ...which are from "1d_tool.py -infile dfile.rall.1D ... -censor_motion ..." 



# CENSORED TRs FROM MOTION + OUTLIER
# =====================================

# censored TRs from combined motion and outlier censor files:
#		censor_fullMonty_combined_2.1D

# ....which is from 1deval -a motion_${subj}_censor.1D -b outcount_${subj}_censor.1D -expr "a*b" > censor_${subj}_combined_2.1D



# DESPIKE INSPECTION FROM FREESURFER:
# =======================================


# SIGNAL TO NOISE INSEPCTION
# ============================


