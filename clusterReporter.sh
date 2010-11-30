#!/bin/sh
#
# LOCATION: 	<location including filename>
# CALL AS:	<usage note or "see invocation section in program body">
#
# !!!! SEE LINES CONTAINING "EDITME" FOR PLACES TO MAKE CHANGES (per computer, per study, parameter tweaks, etc.)
#
# CREATED:	<date> by <whom>
# LAST UPDATED:	<date> by <whom>
#
# DESCRIPTION:
# stowler-clusterReport3.sh worked: gave atlasMask rows and clusterMask subrows
# stowler-clusterReport4.sh adds a second seciton of output: clusterMask rows with atlasMask subrows (via larger outer loop and addition of rowMask and subrowMask nomenclature
# 
# STYSTEM REQUIREMENTS:
#  - awk must be installed for fxnCalc
#  - seq must be installed
#  - column must be installed
#  - each apriori atlas against which a clusterMask might be compared must have a number of files in ${standardParent}:
#    (e.g. standardParent=/Users/stowler/atlases, or standardParent=/data/birc/RESEARCH/atlases)
#        - a multi-intensity atlas mask called ${atlasName}.nii.gz (e.g. 1mmCrosson3roi.nii.gz)
#        - a list of labels in a file called labels_${atlasName}.txt
#        - a blockMasks directory containing block masks aliged to atlas' standard space (e.g. MNI152_T1_1mm_blockMask_BH.nii.gz MNI152_T1_1mm_blockMask_LH.nii.gz MNI152_T1_1mm_blockMask_RH.nii.gz)
#
# INPUT FILES AND PERMISSIONS:
# - clusterMask specified as argument in script call is:
#     - coregistered to match the FSL standard brains (radiological RAI? RPI?)
#     - filled with integer values betwen 1 and 240 inclusive
#
# OTHER ASSUMPTIONS:
#
# TBD:
# - provide choice of atlases
# - peak Rsq for entire cluster and peak Rsq for cluster-atlasRegion intersection
# - coordinate of peak Rsq
#     - coordinate of region CoG instead would allow for coordinate even when user doesn't specify a buck file
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
# bilateral       | (specificROI=valueX)              inBrianNotAtlas=254                    outsideBrain=255
# contralateral   | inAtlasContra=249	               inBrainContraNotAtlas=252	            outsideBrainContra=253
# ipsilateral     | (specificROI=valueX)	            inBrainIpsiNotAtlas=250	               outsideBrainIpsi=251
#
#



# ------------------------- START: fxn definitions ------------------------- #

# fxnCalc is also something I include in my .bash_profile:
# calc(){ awk "BEGIN{ print $* }" ;}
# use quotes if parens are included in your function call:
# calc "((3+(2^3)) * 34^2 / 9)-75.89"
fxnCalc()
{
   awk "BEGIN{ print $* }" ;
}

fxnSetTempDir(){
   # ${tempParent}: parent dir of ${tempDir}(s) where temp files will be stored
   # e.g. tempParent="${blindParent}/tempProcessing"
   # (If tempParent or tempDir needs to include blind, remember to assign value to $blind before calling!)
   # EDITME: $tempParent is something that might change on a per-system, per-script, or per-experiment basis:
   hostname=`hostname -s`
   kernel=`uname -s`
   if [ $hostname = "stowler-mbp" ]; then
      tempParent="/Users/stowler/temp"
   elif [ $kernel = "Linux" ] && [ -d /tmp ] && [ -w /tmp ]; then
      tempParent="/tmp"
   elif [ $kernel = "Darwin" ] && [ -d /tmp ] && [ -w /tmp ]; then
      tempParent="/tmp"
   else
      echo "Cannot find a suitable temp directory. Edit script's tempParent variable. Exiting."
      exit 1
   fi
   # e.g. tempDir="${tempParent}/${startDateTime}-from_${scriptName}.${scriptPID}"
   tempDir="${tempParent}/${startDateTime}-from_${scriptName}.${scriptPID}"
   mkdir $tempDir
   if [ $? -ne 0 ] ; then
      echo ""
      echo "ERROR: unable to create temporary directory $tempDir"
      echo "Exiting."
      echo ""
      exit 1
   fi
}


# deprecated: TBD: rewrite using fxnCalc
#fxnPercentDiff ()
#{
#        sum=`/home/leonardlab/scripts/ucr/scriptbc -p 6 $1 + $2`
#        diff=`/home/leonardlab/scripts/ucr/scriptbc -p 6 $1 - $2`
#        avg=`/home/leonardlab/scripts/ucr/scriptbc -p 6 $sum / 2`
#        percentDiff=`/home/leonardlab/scripts/ucr/scriptbc -p 6 $diff / $avg`
#        percentDiff=`/home/leonardlab/scripts/ucr/scriptbc -p 2 $percentDiff \* 100`
#        echo "${percentDiff}"
#}



# ------------------------- FINISHED: fxn definitions ------------------------- #



# ------------------------- START: check invocation ------------------------- #
#if [ $# != 1 ]; then
#	echo ""
#	echo "please call as bfc_comparison.sh <ucr2blindNum>"
#	echo ""
#	exit
#fi


# Verify that input files exist:
# echo "Verifying that the expected input files exist:"
# echo ""
# ls -l $blahblahblah

# Verify that destination directories exist and are user-writable:
# blindRootParent=`dirname ${blindRoot}`
# echo ""
# echo "Verifying that either ${blindRootParent} or ${blindRoot} exists and is user-writable:"
# echo ""
# ls -ld ${blindRootParent}
# ls -ld ${blindRoot}

# If interactive script: give user a chance to stop or continue depending on whether 
# they're happy with the results of input and output destination seen above:
# echo "Hit ENTER to continue"
# read

# ------------------------- FINISHED: check invocation ------------------------- #



# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"
clusterMask="$1"
intensityVolume="$2"


# second: basic system resources: 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`		# ...assign a constant if not calling from a script
scriptPID="$$"				# ...assign a constant if not calling from a script
scriptUser=`whoami`			# ...used in file and dir names
startDate=`date +%Y%m%d` 		# ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`	# ...used in file and dir names
#cdMountPoint
startDir="`pwd`"
bwDir="/Users/stowler/brainwhere"

# EDITME: change per system
#standardParent=/Users/stowler/atlases  # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
standardParent=${bwDir}/utilitiesAndData/localization  # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
standardTemplate=MNI152_T1_1mm         # standardTemplate is a label used throughout this script
standardTemplateFile=${FSLDIR}/data/standard/${standardTemplate}_brain_mask.nii.gz

# third: variables for filesystem locations, filenames, long arguments, etc.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#intensity="t1bfc0"			# ...to be used in file and folder names
#orientation="radOrig"			# ...ditto


# set image directories:

# ${blindParent}:
# parent dir where each subject's $blindDir reside (e.g. parent of blind1, blind2, etc.)
# e.g. blindParent="/home/leonardlab/images/ucr"
# e.g. allows mkdir ${blindParent}/importedSemiautoLatvens ${blindParent}/blind1

# ${blindDir}: 
# dir for each subject's images and image directories:
# e.g. blindDir="/home/leonardlab/images/ucr/${blind}"
# e.g. blindDir="${blindParent}/${blind}"

# ${origDir}: 
# dir or parent dir where original images will be stored (or are already stored if formatted)
# e.g. origDir="${blindDir}/acqVolumes"

# ${anatRoot}}:
# where the groomed images directory, among others, will live:
# e.g. anatRoot="${blindDir}/anat-${intensity}-${orientation}"

# ${tempParent}:
# parent dir of ${tempDir}s where a brain's temp files will be stored
# (If tempParent or tempDir needs to include blind, remember to assign value to $blind FIRST!)
# e.g. tempParent="${blindParent}/tempProcessing"
# EDITME: changes per system
#tempParent="/Users/stowler/temp"
#tempParent="/home/stowler/temp"

# ${tempDir}:
# dir where temp files for individual processing runs can be stored
# e.g. tempDir="${tempRoot}/${currentDateTime}-from_${scriptName}.${scriptPID}"
#tempDir="${tempParent}/${startDateTime}-from_${scriptName}.${scriptPID}"

# ...source directories for input images:
# (script should copy images from these [probably poorly organized] source directories
# to $origDir
# e.g. sourceT1acqDir="/Users/Shared/cepRedux/acqVolumes"
# e.g. sourceLatvenDir="/Users/Shared/cepRedux/semiautoLatvens"
# e.g. sourceBrainDir="/Users/Shared/cepRedux/semiautoExtractedBrains"
# e.g. sourceFlairDir="/Users/Shared/libon-final/origOrientImageJ" 
# e.g. sourceWMHImaskDir="/Users/Shared/libon-final/masksOrientImageJ"  



# ...brainsuite09 paths and definitions:
#BSTPATH="/data/pricelab/scripts/sdt/brainsuite09/brainsuite09.x86_64-redhat-linux-gnu"
#BSTPATH="/Users/stowler/Downloads/brainsuite09.i386-apple-darwin9.0"
#export BSTPATH
#bstBin="${BSTPATH}/bin/"
#export bstBin
#ATLAS="${BSTPATH}/atlas/brainsuite.icbm452.lpi.v08a.img"
#export ATLAS
#ATLASLABELS="${BSTPATH}/atlas/brainsuite.icbm452.lpi.v09e3.label.img"
#export ATLASLABELS
#ATLASES="--atlas ${ATLAS} --atlaslabels ${ATLASLABELS}"
#export ATLASES

# ...FSL variables
# FSLDIR=""
# export FSLDIR
# FSLOUTPUTTYPEorig="${FSLOUTPUTTYPE}"
# export FSLOUTPUTTYPE=NIFTI_GZ




# ------------------------- FINISHED: definitions and constants ------------------------- #


# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"${scriptName} ${1}\""
      date
echo "#################################################################"
# ------------------------- FINISHED: say hi ------------------------- #


# ------------------------- START: body of program ------------------------- #


# open dataset as Michelle is accustomed to inspecting:
# overlay: specified in excel cluster report
# Talairach View
# Define Overlay:
#  Clusterize: rmm 1.8, vmul 50
#  autoRange: off (set range to 1)
#  Pos? checked
#  3 color panes (divisions set at .20 and .24

echo ""
echo ""
echo "Geometry of your provided clusterMask and intensityVolume must match: "
echo ""
sh ${bwDir}/displayImageGeometry.sh $1 $2
echo "Continue?"
read


fxnSetTempDir
mkdir -p ${tempDir}/atlasMask
mkdir -p ${tempDir}/clusterMask

echo ""
echo "calling augmentAndSplitAtlas.sh to augment and split the canonical atlas (${standardParent}/1mmCrosson3roiOnly.nii.gz)"
# augment and split the canonical atlas:
# EDITME: edit to change atlas used
#sh stowler-augmentAndSplitAtlas.sh ${standardParent}/1mmCrosson3roi.nii.gz ${tempDir}/atlasMask 
sh ${bwDir}/utilitiesAndData/augmentAndSplitAtlas.sh ${standardParent}/1mmCrosson3roiOnly.nii.gz ${tempDir}/atlasMask 
#sh stowler-augmentAndSplitAtlas.sh ${standardParent}/1mmHarvardOxfordCortical.nii.gz ${tempDir}/atlasMask 

echo ""
echo "calling augmentAndSplitAtlas.sh to augment and split the user-specified cluster mask (${clusterMask})"
# augment and split the cluster mask:
sh ${bwDir}/utilitiesAndData/augmentAndSplitAtlas.sh ${clusterMask} ${tempDir}/clusterMask


# loop through main program loop twice: first to create per-atlasMask-region rows and per-clusterMask-region subrows, and then the other way around
mainLoopCounter=0

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
   #DEBUG echo "DEBUG: rowMaskName=$rowMaskName"
   #DEBUG echo "DEBUG: subrowMaskName=$subrowMaskName"
   #DEBUG echo "DEBUG: hit return to continue with stowler-clusterReport.sh $1"
   #DEBUG read


   # for each rowMask region (which will become output rows)...
   while read line; do # start rowRegion outerloop
     # get a bunch of per-rowRegion info before looking at rowRegion-subrowRegion combinations...
           rowRegionIntensity=`echo "${line}" | awk '{print $1}'` 
           rowRegionLabel=`echo "${line}" | awk '{print $2}'` 
           rowRegionName="_${rowMaskName}+${rowRegionIntensity}-${rowRegionLabel}"
           echo "Analyzing rowRegion ${rowRegionName}..."
           # calc total vol of activation in rowMaskRegion:
                 fslmaths -dt float \
                     ${tempDir}/${rowMask}/intensityBin/${rowRegionName}_BH \
                     -mul ${tempDir}/${subrowMask}/${subrowMaskName} \
                     -bin \
                     ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} \
                     -odt char
                 rowRegion_subrowMask_tot_BH_mm3=`fslstats ${tempDir}/${rowMask}/intensityBin/intersection_${rowRegionName}_BH-AND-${subrowMaskName} -V | awk '{print $1}'`
                 echo "rowRegion_subrowMask_tot_BH_mm3 = $rowRegion_subrowMask_tot_BH_mm3"
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
			# DEBUG: subrowRegion_peakValue="PEAK"
			# DEBUG: subrowRegion_peakXYZ="01,20,77"
			3dcalc \
			-a ${intensityVolume} \
			-b ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}.nii.gz \
			-expr 'a*b' \
			-prefix ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz
			ls ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.*
			subrowRegion_peakValue=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -V | awk '{print $1}'`
			# TBD: fix this hacked double-sed:
			subrowRegion_peakXYZ=`fslstats ${tempDir}/${subrowMask}/intensityBin/intersection_${subrowRegionName}_${hem}-AND-${rowRegionName}_${hem}_intensityProduct.nii.gz -x | sed 's/\ /\,/1' | sed 's/\ /\,/1' ` 
                        echo "${subrowRegion_rowRegion_pct}%==${subrowRegionLabel} ${subrowRegion_peakValue} ${subrowRegion_peakXYZ}" >> ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt
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
	    #the two hyphens below are placeholders for peakValue and peakXYZ variables:
            echo "(doesNotIntersect${hem}_of_${subrowMaskName}) - - " >> ${tempDir}/intersectionsOf${rowRegionName}_${hem}.txt
        fi
     done
     # EDITME: path to script called below may need to change per machine. Also the third argument to the script is the character used as a blank-filler (should match the blank filler a few lines down from here)
     # TBD: right now there is a cheat in the called script to put in two extra dashes (for peakValue and peakXYZ)
     sh ${bwDir}/utilitiesAndData/combineUnequalTextFilesIntoTwoColumns.sh ${tempDir}/intersectionsOf${rowRegionName}_LH.txt ${tempDir}/intersectionsOf${rowRegionName}_RH.txt - >> ${tempDir}/intersections_twoHems_noBlanks_${rowRegionName}.txt
     # the two dashes after LH and RH colums below are to open space for the peakValue and peakXYZ variables that appear in subrows below
     rowRegionLocalizationString="${rowRegionIntensity} ${rowRegionLabel} ${rowRegion_subrowMask_tot_BH_mm3} ${rowRegion_subrowMask_outsideBrain_BH_pct} ${rowRegion_subrowMask_inBrain_LH_mm3} ${rowRegion_subrowMask_inBrain_RH_mm3} ${rowRegionLateralityIndex} LH_%composition_per_${subrowMaskName}: - - RH_%composition_per_${subrowMaskName}: - - " 
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


# output report to screen for excel import:
   echo "# CLUSTER REPORT for ${1}"
   echo "# overall laterality index (L-R)/(L+R) for Crosson regions of interest: ${lateralityIndexTotal_atlasMask}"
   echo "# (one line of column headings followed by one row per row region for import into excel):"
   echo "# (rows sorted from row region with greatest volume of activation to row region with least volume of activation)"
   echo ""
   echo "MASK.INTENSITY.VALUE REGION.LABEL MICROLITERS.TOTAL %.OUTSIDE.OF.STANDARD.BRAIN MICROLITERS.LEFT.HEM MICROLITERS.RIGHT.HEM LATERALITY.INDEX COMPOSITION.OF.REGION.IN.LH COMPOSITION.OF.REGION.IN.RH"
   cat ${tempDir}/rowRegionLocalizationStrings_atlasMask.txt | column -t
   echo ""
   echo ""
   echo ""
   echo "(following rows formatted as above, but each row represents a cluster in the clusterMask input by the user"
   echo "MASK.INTENSITY.VALUE REGION.LABEL MICROLITERS.TOTAL %.OUTSIDE.OF.STANDARD.BRAIN MICROLITERS.LEFT.HEM MICROLITERS.RIGHT.HEM LATERALITY.INDEX COMPOSITION.OF.REGION.IN.LH COMPOSITION.OF.REGION.IN.RH"
   cat ${tempDir}/rowRegionLocalizationStrings_clusterMask.txt | column -t


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
