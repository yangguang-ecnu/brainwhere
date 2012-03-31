#!/bin/sh
#
# LOCATION: 	$bwDir
# CALL AS:	(see fxnPrintUsage() below)
#
# !!!! SEE LINES CONTAINING "EDITME" FOR PLACES TO MAKE CHANGES (per computer, per study, parameter tweaks, etc.)
#
# CREATED:	2010     by stowler@gmail.com http://brainwhere.googlecode.com
# LAST UPDATED:	20101209 by stowler@gmail.com
#
# DESCRIPTION:
# Localizes the voxels endorsed in the user-provided cluster mask,
# and provides min and max intensity and corresponding
# coordiantes from user-specified volume 
# 
# STYSTEM REQUIREMENTS:
#  - system utilities: awk, sed, seq, column
#  - each apriori atlas against which a clusterMask might be compared must have a number of files in ${standardParent}:
#    (e.g. standardParent=$bwDir/utilitiesAndData/localization/)
#        - a multi-intensity atlas mask called ${atlasName}.nii.gz (e.g. 1mmCrosson3roi.nii.gz)
#        - a list of labels in a file called labels_${atlasName}.txt
#        - a blockMasks directory containing block masks aliged to atlas' standard space (e.g. MNI152_T1_1mm_blockMask_BH.nii.gz MNI152_T1_1mm_blockMask_LH.nii.gz MNI152_T1_1mm_blockMask_RH.nii.gz)
#
# INPUT FILES AND PERMISSIONS:
# - 3D cluster mask or a lesion mask that has been registered into MNI 1mm
#   space, and is filled only with integer values 1 to 240 inclusive, with 0
#   reserved for background voxels.
# - a 1mmMNI-registered 3D volume containing some value for which the user
#   would like the intensity extrema (and locations) reported. This could be a
#   tstat, r-sq, AUC, or any other intensity of interest. 
#
# OTHER ASSUMPTIONS:
#
# TBD:
# - average HDR w/ variance with each TR (requires access to resp file)
#     - maybe a graph with average at each TR and a measure of variance?
# 
#
#
# A reasonable thing to do is to split the hemispheres into separate masks, and then assign labels for categories that fall outside of your real ROIs:
#
#
#                    inAtlas	                        inBrainButNotAtlas	                  outsideOfStandardBrain
#                 -------------------------------------------------------------------------------------------------------------
# bilateral       | (specificROI=valueX)              inBrianNotAtlas=254                         outsideBrain=255
# contralateral   | inAtlasContra=249	              inBrainContraNotAtlas=252	                  outsideBrainContra=253
# ipsilateral     | (specificROI=valueX)	      inBrainIpsiNotAtlas=250	                  outsideBrainIpsi=251
#
#



# ------------------------- START: fxn definitions ------------------------- #

fxnPrintUsage() {
   #EDITME: remember to update with changes to available atlases
   #REMEMBER: using atlas names instead of a shorter code so that atlas used is unambig. represented in commandline history/notes"
   echo >&2 "clusterReporter.sh - a script to report the atlas-based locations of voxels in a user-provided mask (cluster mask, lesion mask) and, optionally, peak intensity coordinates in a user-provided intensity volume (tstat, R2, etc)"
   echo >&2 ""
   echo >&2 "Usage: clusterReporter.sh                         \\"
   echo >&2 "  -m maskOfClustersOrLesionOrAnythingElse.nii     \\"
   echo >&2 "[ -i intensityVolumeForPeakReporting.nii          \\ ]"
   echo >&2 "  -o /path/to/outputTextFile.txt                  \\"
   echo >&2 "  -a <exact name of ONE atlas on which to localize the your -m mask (see below) >"
   echo >&2 "" 
   echo >&2 "Names of the a priori atlases you may include in command:" 
   echo >&2 "(view any: fslview ${bwDir}/utlitiesAndData/localization/[atlasName].nii.gz)"
   echo >&2 "" 
   echo >&2 "  atlasName                       atlasDescription"
   echo >&2 "  --------------------------------------------------------------------------------------"
   echo >&2 "  1mmHarvardOxfordCortical        48 regions, as distributed with FSL"
   echo >&2 "  1mmHarvardOxfordSubcortical     21 regions, as distributed with FSL"
   echo >&2 "  1mmCrosson3roiOnly              3 custom regions: posterior perisylvian, lateral frontal, medial frontal"
   echo >&2 "  1mmCrosson3roiVer2Only          3 custom regions: posterior perisylvian, lateral frontal, medial frontal"
   echo >&2 "  1mmCrosson3roi                  3 custom regions as above, surrounded by remaining 34 regions from original 48-region mask"
   echo >&2 "  1mmCrosson2roiVisOnly           2 regions from Harvard Oxford cortical: occipital pole and intracalcarine cortex"
   echo >&2 ""
   echo >&2 ""
}


# ------------------------- FINISHED: fxn definitions ------------------------- #


# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"


# second: basic system resources: 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`		# ...assign a constant if not calling from a script
scriptPID="$$"				# ...assign a constant if not calling from a script
scriptUser=`whoami`			# ...used in file and dir names
startDate=`date +%Y%m%d` 		# ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`	# ...used in file and dir names
startDir="`pwd`"
# TBD: test getting $bwDir from environment instead of defining here:
bwDir=/data/birc/RESEARCH/brainwhere
source ${bwDir}/utilitiesAndData/brainwhereCommonFunctions.sh

# EDITME: change per system
#standardParent=/Users/stowler/atlases                 # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
standardParent=${bwDir}/utilitiesAndData/localization  # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
standardTemplate=MNI152_T1_1mm                         # standardTemplate is a label used throughout this script
standardTemplateFile=${FSLDIR}/data/standard/${standardTemplate}_brain_mask.nii.gz


# ------------------------- FINISHED: definitions and constants ------------------------- #

# ------------------------- START: check invocation ------------------------- #

# check for number of arguments:
#if [ $# -lt 1 ] ; then
#   echo ""
#   echo "ERROR: no files specified"
#   echo ""
#   fxnPrintUsage
#   echo ""
#   exit 1
#fi

#initialization of variables that receive values during argument processing
clusterMask=""
intensityVolume=""
atlasName=""
outFile=""

# argument processing with getopt:
set -- `getopt m:i:a:o: "$@"`
[ $# -lt 1 ] && exit 1  # getopt failed
while [ $# -gt 0 ]; do
    case "$1" in
      -m)   clusterMask="${2}"; shift ;;
      -i)   intensityVolume="${2}"; shift ;;
      -a)   atlasName="${2}"; shift ;;
      -o)   outFile="${2}"; shift ;;
      --)   shift; break ;;
      -*)   echo >&2 "usage: $0 - TBD: a short usage note "; exit 1 ;;
       *)   break ;; # terminate while loop
    esac
    shift
done

# Are we missing any required invocation options? Checking:
if [ -z ${clusterMask} ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: you must supply a mask that you would like to localize"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
elif [ -z ${atlasName} ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: you must name the atlas against which you want to localize your mask"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
elif [ -z ${outFile} ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: you must specify an output file for the report text"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
fi

#check for outDir problems: DNE? unwritable?
outDir="`dirname ${outFile}`"
if [ ! -w ${outDir} ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: the specified directory for your output file (${outDir}) does not exist or is not writable by you"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
fi

# check whether the a priori atlas was properly specified on the command line:
if [ ! -r ${bwDir}/utilitiesAndData/localization/${atlasName}.nii.gz ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: ${atlasName} is not a valid atlas name. See valid options below (sensitive to spelling and caps: just copy and paste)"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
fi

# check for bad or nonexistent images :
fxnValidateImages ${clusterMask}
if [ $? -eq 1 ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo "ERROR: ${clusterMask} is not a valid image"
        echo "------------------------------------------------------------------------"
        echo ""
        fxnPrintUsage
        echo ""
        exit 1
fi

if [ ! -z ${intensityVolume} ]; then
        fxnValidateImages ${intensityVolume}
        if [ $? -eq 1 ]; then
                echo ""
		echo "------------------------------------------------------------------------"
                echo "ERROR: ${intensityVolume} is not a valid image"
		echo "------------------------------------------------------------------------"
                echo ""
                fxnPrintUsage
                echo ""
                exit 1
        fi
fi

# TBD: at the time of writing, if no intensityVolume is specified, the clusterMask is assigned to the intensityVolume, which produces nonsensical data for the peak values, but will add code to delete peak columns if there was no $intensityVolume specified
intensityVolumeNotSpecified=0
if [ -z ${intensityVolume} ]; then
	intensityVolume=${clusterMask}
	intensityVolumeNotSpecified=1
fi


#echo ""
#echo "DEBUG: invocation passed all tests. Continue?"
#read


# ------------------------- FINISHED: check invocation ------------------------- #





# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"${scriptName} ${1}\""
      date
echo "#################################################################"
# ------------------------- FINISHED: say hi ------------------------- #


# ------------------------- START: body of program ------------------------- #

# check for matching geometry if flag indicates that intensityVolume was provided on commandline:
if [ ${intensityVolumeNotSpecified} -eq 0 ]; then
	echo ""
	echo ""
	echo "Geometry of your provided clusterMask and intensityVolume must match: "
	echo ""
	sh ${bwDir}/displayImageGeometry.sh ${clusterMask} ${intensityVolume}
	#echo "Continue?"
	#read
fi


fxnSetTempDir
#tempDir=/home/stowler/temp/shortFix
mkdir -p ${tempDir}/atlasMask
mkdir -p ${tempDir}/clusterMask

# TBD: find longer term solution....long clusterMask names are creating errors, so copying 
echo "DEBUG: tempDir=${tempDir}"
echo "DEBUG: clusterMask=${clusterMask}"
echo "DEBUG imcping clusterMask to shortername"
${FSLDIR}/bin/imcp ${clusterMask} ${tempDir}/clusterMaskShortName
clusterMask="${tempDir}/clusterMaskShortName"
echo "DEBUG: new clusterMask is ${clusterMask}"
ls -ltr ${clusterMask}*
echo "DEBUG"
#echo "DEBUG continue?? (ctrl-c to quit)"
#read


echo ""
echo "calling augmentAndSplitAtlas.sh to augment and split the canonical atlas"
# augment and split the canonical atlas:
sh ${bwDir}/utilitiesAndData/augmentAndSplitAtlas.sh ${standardParent}/${atlasName}.nii.gz ${tempDir}/atlasMask 

echo ""
echo "calling augmentAndSplitAtlas.sh to augment and split the user-specified cluster mask (${clusterMask})"
# augment and split the cluster mask:
sh ${bwDir}/utilitiesAndData/augmentAndSplitAtlas.sh ${clusterMask}.nii.gz ${tempDir}/clusterMask


# loop through main program loop twice: first to create per-atlasMask-region rows and per-clusterMask-region subrows, and then the other way around
mainLoopCounter=0

# TBD verify the clusterMask table (table 2) and return to output by changing while condition back to [ $mainLoopCounter -lt 2 ]
while [ $mainLoopCounter -lt 2 ]; do
   # originally script had atlasMask hard coded as the row (outer) loop, and clusterMask hard coded at the subrow (inner) loop. Introduced the $rowMask and $subrowMask syntax and this outerloop as a way to re-run with clusterMask as row (outer) loop.
   # firt time through the main loop: outerLoop (report row) is atlas, and innerLoop (subrows) is cluster mask. Second time through they are reversed
   if [ $mainLoopCounter -eq 0 ]; then 
      rowMask=atlasMask
      subrowMask=clusterMask
   else
      rowMask=clusterMask
      subrowMask=atlasMask
   fi

   echo ""
   echo ""
   echo "================================================================="
   echo "START: localizing activity to regions of the ${rowMask}"
   echo "(should take < 2 minutes per region or cluster)"
         date
   echo "================================================================="
   echo ""
   echo ""

   # these labels_*.txt files are either copied from their existent originals in ${standardParent}, or are created by augmentAndSplitAtlas.sh if they didn't already exist
   rowMaskName=`ls ${tempDir}/${rowMask}/labels_*.txt | xargs basename | sed 's/labels_//' | sed 's/\.txt//' `
   subrowMaskName=`ls ${tempDir}/${subrowMask}/labels_*.txt | xargs basename | sed 's/labels_//' | sed 's/\.txt//' `
   echo "DEBUG: rowMaskName=$rowMaskName"
   echo "DEBUG: subrowMaskName=${subrowMaskName}"
   #echo "DEBUG: hit return to continue with stowler-clusterReport.sh $1"
   #read


   # for each rowMask region (which will become output rows)...
   while read line; do # start rowRegion outerloop
     # get a bunch of per-rowRegion info before looking at rowRegion-subrowRegion combinations...
           rowRegionIntensity=`echo "${line}" | awk '{print $1}'` 
           rowRegionLabel=`echo "${line}" | awk '{print $2}'` 
           rowRegionName="_${rowMaskName}+${rowRegionIntensity}-${rowRegionLabel}"
           echo "Analyzing rowRegion ${rowRegionName}..."
           # calc total vol of activation in rowMaskRegion:

		 # TBD: looks like long paths may be creating errors, so CD'ing in and out
                 fslmaths -dt float \
                     ${tempDir}/${rowMask}/intensityBin/${rowRegionName}_BH \
                     -mul ${tempDir}/${subrowMask}/${subrowMaskName} \
                     -bin \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} \
                     -odt char
                 rowRegion_subrowMask_tot_BH_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} -V | awk '{print $1}'`
                 echo "rowRegion_subrowMask_tot_BH_mm3 = $rowRegion_subrowMask_tot_BH_mm3"

		 # temporarily aborted attempt to fix errors related to too-long path names
		 # mkdir ${tempDir}/safeMul
		 # imcp ${tempDir}/${rowMask}/intensityBin/${rowRegionName}_BH ${tempDir}/safeMul/
		 # imcp ${tempDir}/${subrowMask}/${subrowMaskName} ${tempDir}/safeMul/
		 # cd ${tempDir}/safeMul
                 # fslmaths -dt float \
                 #     ${rowRegionName}_BH \
                 #     -mul ${subrowMaskName} \
                 #     -bin \
		 #     intersectionImage \
		 #     -odt char
                 # rowRegion_subrowMask_tot_BH_mm3=`fslstats intersectionImage -V | awk '{print $1}'`
                 # echo "rowRegion_subrowMask_tot_BH_mm3 = $rowRegion_subrowMask_tot_BH_mm3"
		 # imcp intersectionImage ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}
		 # rm -f ${tempDir}/safeMul/*
		 # cd -
           # calc total vol of activation in rowRegion_subrowMask_BH_mm3 that fall outside of the brain
                 fslmaths -dt float \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} \
                     -mul ${tempDir}/${rowMask}/${standardTemplate}_outsideBrain_BH \
                     -bin \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_outsideBrain_BH \
                     -odt char
                 rowRegion_subrowMask_outsideBrain_BH_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_outsideBrain_BH -V | awk '{print $1}'`
                 if [ ${rowRegion_subrowMask_tot_BH_mm3} -ne 0 ]; then 
                     rowRegion_subrowMask_outsideBrain_BH_pct=`awk "BEGIN{ print $rowRegion_subrowMask_outsideBrain_BH_mm3 / $rowRegion_subrowMask_tot_BH_mm3 * 100 }"`
                 else
                     rowRegion_subrowMask_outsideBrain_BH_pct="0"
                 fi
                 echo "rowRegion_subrowMask_outsideBrain_BH_mm3 = $rowRegion_subrowMask_outsideBrain_BH_mm3"
                 echo "rowRegion_subrowMask_outsideBrain_BH_pct = $rowRegion_subrowMask_outsideBrain_BH_pct"
           # calc total vol of activation in rowRegion_subrowMask_BH_mm3 that fall in LH
                 fslmaths -dt float \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} \
                     -mul ${tempDir}/${rowMask}/${standardTemplate}_inBrain_LH \
                     -bin \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_inBrain_LH \
                     -odt char
                 rowRegion_subrowMask_inBrain_LH_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_inBrain_LH -V | awk '{print $1}'`
                 echo "rowRegion_subrowMask_inBrain_LH_mm3 = $rowRegion_subrowMask_inBrain_LH_mm3"
           # calc total vol of activation in rowRegion_subrowMask_BH_mm3 that fall in RH
                 fslmaths -dt float \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} \
                     -mul ${tempDir}/${rowMask}/${standardTemplate}_inBrain_RH \
                     -bin \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_inBrain_RH \
                     -odt char
                 rowRegion_subrowMask_inBrain_RH_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName}_inBrain_RH -V | awk '{print $1}'`
                 echo "rowRegion_subrowMask_inBrain_RH_mm3 = $rowRegion_subrowMask_inBrain_RH_mm3"
           # calc per-row laterality index = (L-R)/(L+R)
                 if [ ${rowRegion_subrowMask_inBrain_LH_mm3} -ne 0 ] || [ ${rowRegion_subrowMask_inBrain_RH_mm3} -ne 0 ]; then
                    rowRegionLateralityIndex=`awk "BEGIN{ print (${rowRegion_subrowMask_inBrain_LH_mm3}-${rowRegion_subrowMask_inBrain_RH_mm3})/(${rowRegion_subrowMask_inBrain_LH_mm3}+${rowRegion_subrowMask_inBrain_RH_mm3})*100 }"`
                 else
                    rowRegionLateralityIndex=0
                 fi
                 echo "rowRegionLateralityIndex = $rowRegionLateralityIndex"


     # for each subrowMask region execute this inner loop to produce what will be subrows to the rowMask region's main row:
        echo "Analyzing components comprising ${rowRegionName}" `date` " ..."
        while read line; do
            subrowRegionIntensity=`echo "${line}" | awk '{print $1}'` 
            subrowRegionLabel=`echo "${line}" | awk '{print $2}'` 
            subrowRegionName="_${subrowMaskName}+${subrowRegionIntensity}-${subrowRegionLabel}"
            # get per-hemisphere intersection *inside* of brain only:
                  for hem in LH RH; do
                    fslmaths -dt float \
                        ${tempDir}/${subrowMask}/intensityBin/${subrowRegionName}_${hem} \
                        -mul \
                        ${tempDir}/${rowMask}/intensityBin/${rowRegionName}_${hem} \
                        ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem} \
                        -odt char
                    subrowRegion_rowRegion_mm3=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem} -V | awk '{print $1}'`
                    if [ ${subrowRegion_rowRegion_mm3} -ne 0 ]; then 
                        rowRegion_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/${rowRegionName}_${hem} -V | awk '{print $1}'`
                        subrowRegion_rowRegion_pct=`awk "BEGIN{ print ${subrowRegion_rowRegion_mm3}/${rowRegion_mm3}*100 }" `
			# DEBUG: subrowRegion_maxInt="MAX"
			# DEBUG: subrowRegion_maxIntXYZ="01,20,77"
			3dcalc \
			-a ${intensityVolume} \
			-b ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}.nii.gz \
			-expr 'a*b' \
			-prefix ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz &>/dev/null
			ls ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.*
			subrowRegion_maxInt=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -R | awk '{print $2}'`
			subrowRegion_minInt=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -R | awk '{print $1}'`
			# TBD: fix this hacked double-sed:
			subrowRegion_maxIntXYZ=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -x | sed 's/\ /\,/1' | sed 's/\ /\,/1' ` 
			subrowRegion_minIntXYZ=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -X | sed 's/\ /\,/1' | sed 's/\ /\,/1' ` 
                        echo "${subrowRegion_rowRegion_pct}%==${subrowRegionLabel} ${subrowRegion_minInt} ${subrowRegion_maxInt} ${subrowRegion_minIntXYZ} ${subrowRegion_maxIntXYZ}" >> ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt
                    fi
                  done # end of per-hem inner inner loop
        done < ${tempDir}/${subrowMask}/labels_${subrowMaskName}.txt  # done with per-subrow-region inner loop
        echo "...done. `date`"
        echo ""


   # assemble the per-row-region row text, including the per-subrow subrows:
     for hem in LH RH; do
        if [ -s ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt ]; then
            sort -nr -o ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt
        else # this else shouldn't happen if the row has all non-zero values (i.e. outside row areas have been asigned an arbitrary value per note at top of this script)
	    #the four hyphens below are placeholders for minInt, maxInt, minIntXYZ, maxIntXYZ variables:
            echo "(doesNotIntersect${hem}_of_${subrowMaskName}) - - - - " >> ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt
        fi
     done
     # EDITME: path to script called below may need to change per machine. Also the third argument to the script is the character used as a blank-filler (should match the blank filler a few lines down from here)
     # TBD: right now there is a cheat in the called script to put in four extra dashes (for minInt, maxInt, minIntXYZ, maxIntXYZ)
     sh ${bwDir}/utilitiesAndData/combineUnequalTextFilesIntoTwoColumns.sh ${tempDir}/intersectionsOf${rowRegionName}_LH.txt ${tempDir}/intersectionsOf${rowRegionName}_RH.txt - >> ${tempDir}/intersections_twoHems_noBlanks_${rowRegionName}.txt
     # the four dashes after LH and RH colums below are to open space for minInt, maxInt, minIntXYZ, maxIntXYZ in the subrows below:
     rowRegionLocalizationString="${rowRegionIntensity} ${rowRegionLabel} ${rowRegion_subrowMask_tot_BH_mm3} ${rowRegion_subrowMask_outsideBrain_BH_pct} ${rowRegion_subrowMask_inBrain_LH_mm3} ${rowRegion_subrowMask_inBrain_RH_mm3} ${rowRegionLateralityIndex} LH_%composition_per_${subrowMaskName}: - - - - RH_%composition_per_${subrowMaskName}: - - - - " 
     echo "${rowRegionLocalizationString}" >> ${tempDir}/rowRegionLocalizationStrings_${rowMask}.txt
     while read intersection_twoHems; do
       # EDITME: number of dots needs to match number of real fields in rowRegionLocalizationString
       echo "- - - - - - - ${intersection_twoHems}" >> ${tempDir}/rowRegionLocalizationStrings_${rowMask}.txt
     done < ${tempDir}/intersections_twoHems_noBlanks_${rowRegionName}.txt


   done < ${tempDir}/${rowMask}/labels_${rowMaskName}.txt  # end of per-row-region outer loop


   # TBD: sed '//d' unwanted BACKGROUND lines before outputting


#not a type-o: no "$" required:
let mainLoopCounter=mainLoopCounter+1

done # done with main loop controlled by mainLoopCounter


# calcualte overall laterallity index for atlasMask based atlas labels containing "CROSSON"
      grep CROSSON ${tempDir}/rowRegionLocalizationStrings_atlasMask.txt > ${tempDir}/atlasMask/lateralityTotalsCROSSON.txt
      cat ${tempDir}/atlasMask/lateralityTotalsCROSSON.txt | awk '{print $5}' > ${tempDir}/atlasMask/lateralityTotalsCROSSON_LH.txt
      cat ${tempDir}/atlasMask/lateralityTotalsCROSSON.txt | awk '{print $6}' > ${tempDir}/atlasMask/lateralityTotalsCROSSON_RH.txt
      # calculate lateralityTotal_LH
            lateralityTotal_LH_atlasMask=0
            while read line; do 
              lateralityTotal_LH_atlasMask=`awk "BEGIN{ print $line + $lateralityTotal_LH_atlasMask }"`
            done < ${tempDir}/atlasMask/lateralityTotalsCROSSON_LH.txt

      # calculate lateralityTotal_RH
            lateralityTotal_RH_atlasMask=0
            while read line; do 
               lateralityTotal_RH_atlasMask=`awk "BEGIN{ print $line + $lateralityTotal_RH_atlasMask }"`
            done < ${tempDir}/atlasMask/lateralityTotalsCROSSON_RH.txt

      # calc lateralityIndexTotal
            if [ $lateralityTotal_LH_atlasMask -ne 0 ] || [ $lateralityTotal_RH_atlasMask -ne 0 ]; then
               lateralityIndexTotal_atlasMask=`awk "BEGIN{print (${lateralityTotal_LH_atlasMask}-${lateralityTotal_RH_atlasMask})/(${lateralityTotal_LH_atlasMask}+${lateralityTotal_RH_atlasMask})*100 }"`
            else
               lateralityIndexTotal_atlasMask=0
            fi


# output report to screen for excel import, and to $outFile (notice end of EVERY line here):
   echo "# CLUSTER REPORT for ${clusterMask}" | tee -a ${outFile}
   echo "# overall laterality index (L-R)/(L+R) for Crosson regions of interest: ${lateralityIndexTotal_atlasMask}" | tee -a ${outFile}
   echo "# (one line of column headings followed by one row per row region for import into excel):" | tee -a ${outFile}
   echo "# (rows sorted from row region with greatest volume of activation to row region with least volume of activation)" | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   echo "MASK.INTENSITY.VALUE REGION.LABEL MICROLITERS.TOTAL %.OUTSIDE.OF.STANDARD.BRAIN MICROLITERS.LEFT.HEM MICROLITERS.RIGHT.HEM LATERALITY.INDEX COMPOSITION.OF.REGION.IN.LH MIN.INTENSITY.LH MAX.INTENSITY.LH MIN.INTENSITY.XYZ.LH MAX.INTENSITY.XYZ.LH COMPOSITION.OF.REGION.IN.RH MIN.INTENSITY.RH MAX.INTENSITY.RH MIN.INTENSITY.XYZ.RH MAX.INTENSITY.XYZ.RH" | tee -a ${outFile}
   cat ${tempDir}/rowRegionLocalizationStrings_atlasMask.txt | column -t | tee -a ${outFile}
   # TBD: just kill the extra columns if an intensity mask wasn't provided?
   echo "" | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   # TBD: put these back in after troubleshooting table2
   echo "(following rows formatted as above, but each row represents a cluster in the clusterMask input by the user" | tee -a ${outFile}
   echo "MASK.INTENSITY.VALUE REGION.LABEL MICROLITERS.TOTAL %.OUTSIDE.OF.STANDARD.BRAIN MICROLITERS.LEFT.HEM MICROLITERS.RIGHT.HEM LATERALITY.INDEX COMPOSITION.OF.REGION.IN.LH MIN.INTENSITY.LH MAX.INTENSITY.LH MIN.INTENSITY.XYZ.LH MAX.INTENSITY.XYZ.LH COMPOSITION.OF.REGION.IN.RH MIN.INTENSITY.RH MAX.INTENSITY.RH MIN.INTENSITY.XYZ.RH MAX.INTENSITY.XYZ.RH" | tee -a ${outFile}
   cat ${tempDir}/rowRegionLocalizationStrings_clusterMask.txt | column -t | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   echo "" | tee -a ${outFile}
   # TBD: just kill the extra columns if an intensity mask wasn't provided?

echo ""
echo ""
echo "Wrote cluster report to ${outFile}:"
ls -l ${outFile}

echo ""
echo ""
echo "================================================================="
echo "FINISHED: localizing activity to row regions (rows=atlas regions)"
      date
echo "================================================================="
echo ""
echo ""




# ------------------------- FINISHED: body of program ------------------------- #


# ------------------------- START: say bye and restore environment ------------------------- #
echo ""
echo "#################################################################"
echo "FINISHED: \"${scriptName} ${1}\""
      date
echo "#################################################################"
echo ""
echo ""
echo ""
export FSLOUTPUTTYPE=${FSLOUTPUTTYPEorig}
# ------------------------- END: say bye and restore environment ------------------------- #
