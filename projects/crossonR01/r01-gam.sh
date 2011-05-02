#!/bin/sh
#
# LOCATION: 	  ~stowler/scripts/stowler-r01-gam-post3mo.sh
# USAGE:          (see fxnPrintUsage() below)
#
# CREATED:	  201008?? by stowler@ufl.edu
# LAST UPDATED:	  20110121 by stowler@ufl.edu
#
# DESCRIPTION:
# Entire r01 gamma variate processing pipeline.
# 
# STYSTEM REQUIREMENTS:
#  - awk must be installed for fxnCalc
#   <list or describe others>
#
# INPUT FILES AND PERMISSIONS:
# <list or describe>
#
# OTHER ASSUMPTIONS:
# <list or describe>


# ------------------------- START: fxn definitions ------------------------- #

source $bwDir/utilitiesAndData/brainwhereCommonFunctions.sh

fxnPrintUsage() {
   #EDITME: customize for each script:
   echo >&2 "$0 - a script to process r01 INT2 data"
   echo >&2 "Usage: $0 [-s] [-g] [-p] [-c] -b <blindNumber> -t <session>"
   echo >&2 "  -s   screen input files"
   echo >&2 "  -g   gather input files"
   echo >&2 "  -p   process input files into 1mmMNI152-registered cluster maps"
   echo >&2 "  -c   generate cluster reports"
   echo >&2 "  -b   blindNumber (e.g. INT2_s01)"
   echo >&2 "  -t   session (pre, post, or 3mo)"
}


# ------------------------- FINISHED: fxn definitions ------------------------- #



# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"


# second: basic system resources:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`		      # ...assign a constant here if not calling from a script
scriptPID="$$"				            # ...assign a constant here if not calling from a script
#scriptDir=""				            # ...used to get to other scripts in same directory
scriptUser=`whoami`			         # ...used in file and dir names
startDate=`date +%Y%m%d` 		      # ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`	# ...used in file and dir names

studyDir="/data/birc/RESEARCH/RO1/SUBJECTS/INT2"


# ------------------------- FINISHED: definitions and constants ------------------------- #



# ------------------------- START: invocation ------------------------- #

# check for number of arguments
if [ $# -lt 1 ] ; then
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi

# store for later reference
allArgs="$@"

# initialization of variables that receive values during argument processing:
screen=0
gather=0
process=0
generateClusterReport=0
blindList=0
sessionRequested=0

# use getopt to process arguments:
set -- `getopt sgpcb:t: "$@"`
[ $# -lt 1 ] && exit 1	# getopt failed
while [ $# -gt 0 ]
do
    case "$1" in
      -s)   screen=1
            ;;
      -g)   gather=1
            ;;
      -p)   process=1
            ;;
      -c)   generateClusterReport=1
            ;;
      -b)   blindList="${2}"; shift
            ;; 
      -t)   sessionRequested="${2}"; shift
            ;;
      --)	shift; break
            ;;
      -*)   fxnPrintUsage; exit 1
             ;;
       *)	break
            ;;		# terminate while loop
    esac
    shift
done


# ------------------------- FINISHED: invocation ------------------------- #



# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"${scriptName} ${allArgs}\""
      date
echo "#################################################################"
echo ""
echo ""
# ------------------------- FINISHED: say hi ------------------------- #



# ------------------------- START: body of program ------------------------- #

fxnSetTempDir                 # setup and create $tempDir if necessary
# TBD: Verify that destination directories exist and are user-writable:
#outDir="${HOME}/r01postOnlyBW"
outDir="/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniRefweight"
mkdir -p ${outDir}

echo "DEBUG: blindList=${blindList}"

if [ $screen -eq 1 ]; then
	echo ""
	echo ""
	echo "================================================================="
	echo "START: screen input files (anat+orig, lesion, epi, stim)"
	echo "(should take about TBD minutes)"
	      date
	echo "================================================================="
	echo ""
	echo ""


	######echo ""
	######echo "Screening Michelle's previous cluster reports:"
	######echo ""
	######	# Michelle: 
	######	# missing for s04, but have for s06 s11 s16 s19	
	######	for blind in `echo ${blindList}`; do
	######		for session in pre post 3mo; do
	######			ls -al ${studyDir}/${blind}/${session}/scriptfiles/*clust
	######		done
	######		echo ""
	######	done


	######echo ""
	######echo "Screening JT's previous GAM output:"
	######	# missing thresholded stim for s06 (but has stim.resp.irfcorr5), but have for pre of s04, s11, s16, and s19
	######	for blind in `echo ${blindList}`; do
	######		for session in pre post 3mo; do
	######			for condition in stim allresp; do
	######				ls -al ${studyDir}/${blind}/${session}/afnifiles/${blind}.${session}.${condition}.resp.irfcorr5.*HEAD
	######			done
	######		done
	######		echo ""
	######	done


	######echo ""
	######echo ""
	######echo "Screening stim files:"
	######echo ""
	####### INTERESTING: wc output demonstrates 2137 instead of 2136 characters:
	####### 1068 1068 2137 /data/birc/RESEARCH/RO1/SUBJECTS/INT2/INT2_s04/pre/stimfiles/INT2_s04_pre.concat_allresp.1D
	####### 1068 1068 2136 /data/birc/RESEARCH/RO1/SUBJECTS/INT2/INT2_s04/pre/stimfiles/INT2_s04_pre.stim_concat.1D
	####### 1068 1068 2137 /data/birc/RESEARCH/RO1/SUBJECTS/INT2/INT2_s06/post/stimfiles/INT2_s06_post.concat_allresp.1D
	####### 1068 1068 2136 /data/birc/RESEARCH/RO1/SUBJECTS/INT2/INT2_s06/post/stimfiles/INT2_s06_post.stim_concat.1D
	######for blind in `echo ${blindList}`; do
	######	for session in pre post 3mo; do
	######		#ls -ald ${studyDir}/${blind}/${session}/stimfiles/*${session}*concat*
	######		wc ${studyDir}/${blind}/${session}/stimfiles/${blind}_${session}.concat_allresp.1D
	######		wc ${studyDir}/${blind}/${session}/stimfiles/${blind}_${session}.stim_concat.1D
	######		echo ""
	######	done
	######done


	echo ""
	echo ""
	echo "Screening lesions:"
	#fixed: mv INT2_s04_lesion.nii.gz INT2_s04_lesion_RPI.nii.gz && 3dresample -orient rpi -prefix INT2_s04_lesion.nii.gz -inset INT2_s04_lesion_LPI.nii.gz
	#fixed: INT2_s01_lesion.nii.gz INT2_s01_lesion_LPI.nii.gz  &&  3dresample -orient RPI -prefix INT2_s01_lesion.nii.gz -inset INT2_s01_lesion_LPI.nii.gz
	#fixed:  mv INT2_s02_lesion.nii.gz INT2_s02_lesion_LPI.nii.gz && 3dresample -orient RPI -prefix INT2_s02_lesion.nii.gz -inset INT2_s02_lesion_LPI.nii.gz

	for blind in `echo ${blindList}`; do
		fxnValidateImages /data/home/stowler/lesionAttempt0/${blind}_lesion.nii.gz
	done
	lesionList=""
	for blind in `echo ${blindList}`; do
		lesionList="${lesionList} /data/home/stowler/lesionAttempt0/${blind}_lesion.nii.gz"
	done
	sh ${bwDir}/displayImageGeometry.sh "${lesionList}"


	echo ""
	echo ""
	echo "Screening anatomics:"
	#fixed: mv INT2_s04_T1.nii.gz INT2_s04_T1_LPI.nii.gz && 3dresample -orient rpi -prefix INT2_s04_T1.nii.gz -inset INT2_s04_T1_LPI.nii.gz
	anatomicList=""
	for blind in `echo ${blindList}`; do
		for session in `echo ${sessionRequested}`; do
			#fxnValidateImages /data/home/stowler/lesionAttempt0/${blind}_T1.nii.gz
			fxnValidateImages ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.3danat+orig.HEAD
			anatomicList="${anatomicList} ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.3danat+orig.HEAD"
		done
	done
	sh ${bwDir}/displayImageGeometry.sh "${anatomicList}"


	# TBD: wrap in if statemet so only happens if session = post or 3mo
	if [ "${session}" = "post" ] || [ "${session}" = "3mo" ]; then 
		echo "DEBUG session is post or 3mo!!! continue?"
		echo "DEBUG: disabling all read statements until I test for interactivity"
		# read
		echo ""
		echo ""
		echo "Screening PRE session anatomics needed for coregistration to lesion:"
		#fixed: mv INT2_s04_T1.nii.gz INT2_s04_T1_LPI.nii.gz && 3dresample -orient rpi -prefix INT2_s04_T1.nii.gz -inset INT2_s04_T1_LPI.nii.gz
		anatomicPreList=""
		for blind in `echo ${blindList}`; do
			for session in `echo ${sessionRequested}`; do
				#fxnValidateImages /data/home/stowler/lesionAttempt0/${blind}_T1.nii.gz
				#fxnValidateImages /data/home/stowler/r01preOnly/${blind}/pre/afnifiles/${blind}_${session}_t1.nii.gz
				fxnValidateImages /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1.nii.gz
				#fxnValidateImages /data/home/stowler/r01preOnly/${blind}/pre/afnifiles/${blind}_${session}_t1_brain.nii.gz
				fxnValidateImages /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1_brain.nii.gz
				anatomicPreList="${anatomicPreList} /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1.nii.gz /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1_brain.nii.gz"
			done
		done
		sh ${bwDir}/displayImageGeometry.sh "${anatomicPreList}"
	fi


	
	echo ""
	echo ""
	echo "Screening EPI volumes:"
	epiList=""
	for blind in `echo ${blindList}`; do
		for session in `echo ${sessionRequested}`; do
			fxnValidateImages ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.epi+orig.HEAD
			epiList="${epiList} ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.epi+orig.HEAD"
		done
	done
	sh ${bwDir}/displayImageGeometry.sh "${epiList}"



	echo ""
	echo ""
	echo "Screening buck and resp files to which we may apply gamma thresholding:"
	buckList=""
	respList=""
	for blind in `echo ${blindList}`; do
		for session in `echo ${sessionRequested}`; do
			for condition in stim allresp; do 
				fxnValidateImages ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.buck+orig.HEAD
				fxnValidateImages ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.resp+orig.HEAD
				buckList="${buckList} ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.buck+orig.HEAD"
				respList="${respList} ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.resp+orig.HEAD"
			done # end of condition loop
		done # end of session loop
	done # end of blind loop
	sh ${bwDir}/displayImageGeometry.sh "${buckList}"
	sh ${bwDir}/displayImageGeometry.sh "${respList}"

	
	# TBD: allow for non-interactive switch that will skip this
	echo ""
	echo -n "If happy with screening, hit Return to continue or CTRL-C to quit."
	echo "DEBUG: disabling all read statements until I test for interactivity"
	#read


	echo ""
	echo ""
	echo "================================================================="
	echo "FINISHED: screening input images "
	      date
	echo "================================================================="
	echo ""
	echo ""
fi


# ================================================================= #

if [ $gather -eq 1 ]; then
        # NOTE: .nii.gz is about 25% size of .nii on average
        echo ""
        echo ""
        echo "================================================================="
        echo "START: gather input files (anat and epi's => RPI orientation)"
        echo "(should take about 25 minutes, or 6 minutes per written GB)"
              date
        echo "================================================================="
        echo ""
        echo ""

	echo "DEBUG EXISTING DIR: ls -ltr ${outDir}/${blind}/${session}/afnifiles:"
	echo ""
	ls -ltr ${outDir}/${blind}/${session}/afnifiles:
        echo "OK to rm -fr ${outDir}/${blind}/${session}/afnifiles ? (return to continue, ctrl-c if not ok)"
	echo "DEBUG: disabling all read statements until I test for interactivity"
        #read
        rm -fr ${outDir}/${blind}/${session}/afnifiles


	# create directories:
        for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			mkdir -p ${outDir}/${blind}/${session}/afnifiles
		done 
        done 


        echo ""
        echo ""
        echo "Gathering t1 images:"
        echo ""
        t1list=""
        for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			3dresample -orient RPI -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz -inset ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.3danat+orig.HEAD
			ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz
			t1list="${t1list} ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz"
		done # end of session loop
        done # end of blind loop
        sh ${bwDir}/displayImageGeometry.sh "${t1list}"


       	echo ""
        echo ""
        echo "Gathering epi images:"
        echo ""
        epiList=""
        for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			3dresample -orient RPI -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi.nii.gz -inset ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.epi+orig.HEAD
			ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi.nii.gz
			epiList="${epiList} ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi.nii.gz"
		done # end of session loop
        done # end of blind loop
        sh ${bwDir}/displayImageGeometry.sh "${epiList}"


        echo ""
        echo ""
        echo "Gathering resp and buck legacy images:"
        echo ""
        respList=""
        buckList=""
	rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp*
	rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck*
	rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz
	for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			for condition in stim allresp; do
				3dresample -orient RPI -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp -inset ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.resp+orig.HEAD
				3dresample -orient RPI -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck -inset ${studyDir}/${blind}/${session}/afnifiles/${blind}_${session}.${condition}.buck+orig.HEAD
                        	# 3dresample output for buck files is constrained to HEAD/BRIK, so converting to NIFTI:
				3dAFNItoNIFTI -float -verb -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp+orig.HEAD
				3dAFNItoNIFTI -float -verb -prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck+orig.HEAD
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp+orig.HEAD
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp+orig.BRIK
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck+orig.HEAD
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck+orig.BRIK
				ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp.nii.gz
				ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz
				respList="${respList} ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp.nii.gz"
				buckList="${buckList} ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz"
			done # end of condition loop
		done # end of session loop
	done # end of blind loop
        sh ${bwDir}/displayImageGeometry.sh "${respList}"
        sh ${bwDir}/displayImageGeometry.sh "${buckList}"



        echo ""
        echo ""
        echo "================================================================="
        echo "FINISHED: gathered input files"
              date
        echo "================================================================="
        echo ""
        echo ""
fi



# ================================================================= #

if [ $process -eq 1 ]; then
	for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			# TBD: have I verified that sessions can only equal pre, post, or 3mo from user?
			if [ "${session}" = "post" ] || [ "${session}" = "3mo" ]; then
			# TBD: wrap in test for session == post or 3mo
			##################### between these lines is unique to post and 3mo #################################
				mv -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig.nii.gz
				# ================================================================= #
				# skull-strip and register to the pre T1 which is aligned with the lesion:
				echo ""
				echo ""
				echo "Skull-striping original T1 for registration to pre T1..."
				echo ""
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig_brain.nii.gz
				bet ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig_brain.nii.gz -R -v
				echo ""
				echo "...done:"
				ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig_brain.*
				echo ""
				echo ""

				echo ""
				echo ""
				echo "Linear transformation of extracted T1 to pre session's extracted T1 takes about two minutes..."
				# TBD EDITME: the path and name of extracted pre session T1 may change and need updating here:
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_2preT1_affine_transf.mat
				flirt \
				     -in ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig_brain.nii.gz \
				     -ref /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1_brain.nii.gz \
				     -omat ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_2preT1_affine_transf.mat
				echo "...done:"
				ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_2preT1_affine_transf.mat

				echo ""
				echo ""
				echo "Applying extracted T1 transformation matrix to unextracted T1:"
				# EDITME: the path and name of unextracted pre session T1 may change and need updating here:
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_orig.nii.gz
				flirt \
					-in ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_REALorig.nii.gz \
					-ref /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma/${blind}/pre/afnifiles/${blind}_pre_t1.nii.gz \
					-applyxfm -init ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_2preT1_affine_transf.mat \
					-out ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_orig.nii.gz
				echo "...done:"
				ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_orig.nii.gz
			##################### between these lines is unique to post and 3mo #################################
			# else this is pre and just needs this command to prep for registerTo1mmMNI152.sh:
			else
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_orig.nii.gz
			fi
				
			# skull-strip, then register T1 to 1mmMNI152 space (will handle EPI on own):
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_t1.nii.gz 			${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_brain.nii.gz 			${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_warped.nii.gz 		${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_warped.nii.gz
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_brain_warped.nii.gz 		${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain_warped.nii.gz
			sh ${bwDir}/registerTo1mmMNI152.sh \
			-s ${blind} \
			-t ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_orig.nii.gz \
			-o ${outDir}/${blind}/${session}/afnifiles \
			-l /data/home/stowler/lesionAttempt0/${blind}_lesion.nii.gz

			# rename images for consistency:
			mv ${outDir}/${blind}/${session}/afnifiles/${blind}_t1.nii.gz 				${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1.nii.gz
			mv ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_brain.nii.gz 			${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz
			mv ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_warped.nii.gz 			${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_warped.nii.gz
			mv ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_brain_warped.nii.gz 		${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain_warped.nii.gz
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_lesion.nii.gz ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_lesion.nii.gz 		${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_lesion.nii.gz
			fi
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_lesionInverted.nii.gz ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_lesionInverted.nii.gz 	${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_lesionInverted.nii.gz
			fi
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_lesion_warped.nii.gz ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_lesion_warped.nii.gz 	${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_lesion_warped.nii.gz
			fi
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_affine_transf.mat ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_affine_transf.mat 		${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_affine_transf.mat
			fi
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_to_MNI152_T1_2mm.log ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_t1_to_MNI152_T1_2mm.log 	${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_to_MNI152_T1_2mm.log
			fi
			if [ -s ${outDir}/${blind}/${session}/afnifiles/${blind}_nonlinear_transf.nii.gz ]; then
				mv ${outDir}/${blind}/${session}/afnifiles/${blind}_nonlinear_transf.nii.gz 	${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_nonlinear_transf.nii.gz
			fi

			echo ""
			echo ""
			echo "calculation of linear EPI transformation takes about two minutes..."
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat
			flirt \
				-ref ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain \
				-in ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi \
				-dof 7 \
				-omat  ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat
			echo "...done:"
			ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat
			echo ""
			echo "" 


			ls -lr ${outDir}/${blind}/${session}/afnifiles/
			#echo ""
			#echo "DEBUG: happy with registration results? (ctrl-c to quit, return to continue)"
			#read

			#threshDeconRsq=.10
			#threshGamCorr=.8
			# filter by 5 gamma functions that approximate HRFs of varying TTPs and width, and threshold at Rsq=.10 :
			for condition in stim allresp; do
				echo ""
				echo ""
				echo "Filtering ${blind} ${session} ${condition} resp and buck files against five ideal gamma variantes, and thresholding deconvolution at  at Rsq=.10 :"
				echo ""
				# create the gamma correlation file while also thresholding out voxels with Rsqs < some threshold:
				rm -f  ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.nii.gz
				sh ~/scripts/stowler-gamFilter-5gams.sh \
					-t 1.7 \
					-r .10 \
					-i ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.resp.nii.gz \
					-b ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz \
					-o ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.nii.gz
				
				# threshold the gamma correlation file to some high correlation criterion (.8):
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.nii.gz
				3dmerge \
					-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.nii.gz \
					-1clip .8 \
					${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.nii.gz'[1]'

				# create a mask from that thresholded correlation criterion:
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.mask.nii.gz
				3dcalc \
					-datum float \
					-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.mask.nii.gz \
					-a ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.nii.gz \
					-expr 'step(a)'

				# apply that mask to whatever your volume of interest is (AUC, buck[0], etc.)
				rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck_irfcorr5.thresh10.gammaThresh8.nii.gz
				3dcalc \
					-datum float \
					-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck_irfcorr5.thresh10.gammaThresh8.nii.gz \
					-a ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}.buck.nii.gz'[0]' \
					-b ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_${condition}_irfcorr5.thresh10.gammaThresh8.mask.nii.gz \
					-expr 'a*b'

			done # end of condition loop


			# merge conditions: new stim and allresp buckets
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz
			3dmerge \
			-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz \
			-gmax  ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_stim.buck_irfcorr5.thresh10.gammaThresh8.nii.gz ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_allresp.buck_irfcorr5.thresh10.gammaThresh8.nii.gz


			# ...and now apply warp to the buck file :
			echo ""
			echo ""
			echo "applying nonlinear warp to buck (about two minutes)..."
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz
			applywarp \
			     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
			     --in=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.nii.gz \
			     --warp=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_nonlinear_transf.nii.gz \
			     --premat=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat \
			     --out=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz

			ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped*
			sh ${bwDir}/displayImageGeometry.sh ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped*

			# ...and as a way to visually verify quality of EPI transformation, create a 3D "average" EPI volume for the session, and apply same registrations to it.
			# The func2struct and warped version of this will be used to visually verify quality of EPI transformations.
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged.nii.gz
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged_func2struct.nii.gz
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged_warped.nii.gz
			fslmaths ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi.nii.gz -Tmean ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged.nii.gz
			flirt \
				-in ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged.nii.gz \
				-ref ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_t1_brain.nii.gz \
				-applyxfm -init ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat \
				-out ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged_func2struct.nii.gz
			applywarp \
			     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
			     --in=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged.nii.gz \
			     --warp=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_nonlinear_transf.nii.gz \
			     --premat=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_func2struct.mat \
			     --out=${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_epi_averaged_warped.nii.gz
			
			echo ""
			echo ""
			echo "================================================================="
			echo "FINISHED: processing ${blind} ${session}"
			      date
			echo "================================================================="
			echo ""
			echo ""
		#echo "DEBUG: proceed to next session?"
		#read
		done # end of session loop
	#echo "DEBUG: proceed to next blind?"
	#read
	done # end of blind loop
fi

# ================================================================= #

if [ $generateClusterReport -eq 1 ]; then
	for blind in ${blindList}; do
		for session in `echo ${sessionRequested}`; do
			echo ""
			echo ""
			echo "================================================================="
			echo "START: generating cluster report(s) for ${blind} ${session}"
			echo "(should take about TBD minutes)"
			      date
			echo "================================================================="
			echo ""
			echo ""

			# 3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -1noneg -2thresh -0.2 0.2 1.8 50 ${buck_file}
			#	-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clusters \
			ls -l ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz.nii.gz
			#3dclust \
			#	-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clusters.nii.gz \
			#	-1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.16 0.16 -dxyz=1 -1clust_order 1\
			#	1.75 50 \
			#	${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz.nii.gz 
			#ls -ltr ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clusters*
	


	
			# 0. cd outdir	
			# 1. create cluster mask in afni
			# 2. 3dAFNItoNIFTI -verb -float -prefix /home/stowler/toScreen-r01clusterReports/INT2_s01_clust_mask.nii.gz INT2_s01_clust_mask+tlrc.HEAD
			# 3. cd -
			# 4. generate blind x session cluster report:
			#change to outDir
			#
			# the equilavalent of 3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -2thresh -0.16 0.16 -dxyz=1 1.75 50 [INPUT BUCK]
			# .....is 3dmerge -dxyz=1 -1clust_order 1.75 50 -2thresh -0.16 0.16 -1dindex 0 -1tindex 0 -prefix [OUTPUT FILE] [INPUT BUCK] 
			# TBD: testing at 100 ul instead of 50 ul
			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_maskBW.nii.gz
			3dmerge \
			-dxyz=1 \
			-1clust_order 1.75 100 \
			-2thresh -0.12 0.12 \
			-1dindex 0 -1tindex 0 \
			-prefix ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_maskBW.nii.gz \
			${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz.nii.gz

			rm -f ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer2Only.txt
			${bwDir}/clusterReporter.sh \
                        -m ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_maskBW.nii.gz \
                        -o ${outDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer2Only.txt \
                        -a 1mmCrosson3roiVer2Only

			echo ""
			echo ""
			echo "================================================================="
			echo "FINISHED: generated cluster reports for ${blind} ${session}"
			      date
			echo "================================================================="
			echo ""
			echo ""
		done
	done
fi

# ------------------------- FINISHED: body of program ------------------------- #


# ------------------------- START: say bye and restore environment ------------------------- #

rm -fr ${tempDir}
echo ""
echo "#################################################################"
echo "FINISHED: \"${scriptName} ${allArgs}\""
      date
echo "#################################################################"
echo ""
echo ""
echo ""
export FSLOUTPUTTYPE=${FSLOUTPUTTYPEorig}

# ------------------------- END: say bye and restore environment ------------------------- #



