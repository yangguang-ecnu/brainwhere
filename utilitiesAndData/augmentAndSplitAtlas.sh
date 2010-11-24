#!/bin/sh
#
# LOCATION:     /data/birc/RESEARCH/atlases/stowler-localization/stowler-augmentAndSplitAtlas.sh
# CALL AS:      (see invocation section below)
#
# CREATED:      August 2010 by stowler@gmail.com
# LAST UPDATED: 20100827 by stowler@gmail.com
#
# DESCRIPTION:
# Accepts mni152-registered multi-value masks as argument (cluster masks, atlases, etc), and outputs a cluster report.
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
# start: bilateral atlas has zeros in background and 1-200 in foreground
# assumes atlas is completely enclosed by ?
# should LH and RH be replace by CH and IH ?
# canonical atlases: can be liberal, so maybe should use ${atlas}_inBrain for everything since images are warped to MNI brain.
#  something like fslmaths -dt float ${atlas} -mul ${standardTemplate}_inBrain_BH ${atlas}_MNItight -odt char
# TBD: check: no ".nii" in code


# ------------------------- START: fxn definitions ------------------------- #

# fxnCalc is also something I include in my .bash_profile:
# calc(){ awk "BEGIN{ print $* }" ;}
# use quotes if parens are included in your function call:
# calc "((3+(2^3)) * 34^2 / 9)-75.89"
fxnCalc()
{
   awk "BEGIN{ print $* }" ;
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
if [ $# != 2 ]; then
        echo ""
        echo "please call as stowler-augmentAndSplitAtlas.sh <atlas or cluster mask> <output directory>"
        echo ""
        exit
fi

# Verify that input files exist:
if [ ! -r "${1}" ]; then
        echo ""
        echo "${1} does not exist or is not readable. Please specify another file."
        echo ""
        exit
fi

# TBD: verify that input file has intensities of integers only, with maxIntensity < about 240

# Verify that destination directories exist and are user-writable:
# blindRootParent=`dirname ${blindRoot}`
# echo ""
# echo "Verifying that either ${blindRootParent} or ${blindRoot} exists and is user-writable:"
# echo ""
# ls -ld ${blindRootParent}
# ls -ld ${blindRoot}

# If interactive script: give user a chance to stop or continue depending on whether 
# they're happy with the results of input and output destination seen above:
echo ""
echo "This will create a bunch of files in directory ${2}/ , which may overwrite older files in that directory if it already exists."
# echo "Hit ENTER to continue, or CTRL-C to quit."
# read

# ------------------------- FINISHED: check invocation ------------------------- #



# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"
atlasFile="${1}"
atlas=`basename ${atlasFile} | xargs remove_ext `
#atlas=crosson39regions
outputDir="${2}"


# second: basic system resources:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`                # ...assign a constant if not calling from a script
scriptPID="$$"                          # ...assign a constant if not calling from a script
#scriptDir=""                           # ...used to get to other scripts in same directory
scriptUser=`whoami`                     # ...used in file and dir names
startDate=`date +%Y%m%d`                # ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`      # ...used in file and dir names
startDir="`pwd`"
#cdMountPoint


# third: variables for filesystem locations, filenames, long arguments, etc.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# intensity="t1bfc0"                    # ...to be used in file and folder names
# orientation="radOrig"                 # ...ditto


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

# ${tempDir}:
# dir where temp files for individual processing runs can be stored
# e.g. tempDir="${tempRoot}/${startDateTime}-from_${scriptName}.${scriptPID}"

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

# EDITME: change per system
bwDir="/Users/stowler/brainwhere"
standardParent=${bwDir}/localization  # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
#standardParent=/Users/stowler/atlases  # standardParent is the parent directory of where I keep things like customized standardTemplates and atlases
standardTemplate=MNI152_T1_1mm         # standardTemplate is a label used throughout this script
standardTemplateFile=${FSLDIR}/data/standard/${standardTemplate}_brain_mask.nii.gz


# ------------------------- FINISHED: definitions and constants ------------------------- #


# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"$ ${scriptName} ${1} ${2}\""
      date
echo "#################################################################"
echo ""
echo ""
# ------------------------- FINISHED: say hi ------------------------- #


# ------------------------- START: body of program ------------------------- #



echo ""
echo ""
echo "================================================================="
echo "START: augment the input atlas/clusterMask with hemispheres and gross regions"
echo "(should take about 2 minutes)"
      date
echo "================================================================="
echo ""
echo ""

# to manually remove previous files before re-running:
# $ rm -f ${standardTemplate}_in* ${standardTemplate}_out* ${atlas}_in* ${atlas}_out*

mkdir -p ${outputDir}
imcp ${atlasFile} ${outputDir}/
cd "${outputDir}"
atlasFile=`basename ${atlasFile}`

# create variants of standardTemplate mask:

   echo ""
   echo "Creating gross divisions of ${standardTemplateFile} ..."

   # create ${standardTemplate}_inBrain_BH/LH/RH:
   cp ${standardTemplateFile} ${standardTemplate}_inBrain_BH.nii.gz
   #cp ${FSLDIR}/data/standard/${standardTemplate}_brain_mask_dilMsdt.nii.gz ${standardTemplate}_inBrain_BH.nii.gz
   fslmaths -dt float ${standardTemplate}_inBrain_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${standardTemplate}_inBrain_LH -odt char
   fslmaths -dt float ${standardTemplate}_inBrain_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${standardTemplate}_inBrain_RH -odt char
   # create ${standardTemplate}_outsideBrain_BH/LH/RH 
   fslmaths -dt float ${standardTemplate}_inBrain_BH -sub 1 -abs ${standardTemplate}_outsideBrain_BH -odt char
   fslmaths -dt float ${standardTemplate}_outsideBrain_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${standardTemplate}_outsideBrain_LH -odt char
   fslmaths -dt float ${standardTemplate}_outsideBrain_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${standardTemplate}_outsideBrain_RH -odt char

   echo "...done."



# apply variants of $standardTemplate masks to create 0/1 binary masks from $atlas
# likely to be reported as ROIs: ${atlas}_outsideBrain_BH, ${atlas}_inBrainNotAtlas_LH/RH

   echo ""
   echo "Applying gross divisions of ${standardTemplateFile} to ${atlasFile} ..."

   # _LH/RH:
   fslmaths -dt float ${atlasFile} -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${atlas}_LH -odt char
   fslmaths -dt float ${atlasFile} -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${atlas}_RH -odt char

   # inBrain_BH/LH/RH:
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_inBrain_BH ${atlas}_inBrain_BH -odt char
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_inBrain_LH ${atlas}_inBrain_LH -odt char
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_inBrain_RH ${atlas}_inBrain_RH -odt char
   # outsideBrain_BH/LH/RH (BH is a likely reported ROI):
   # This is a good check for alignment between canonical atlas and standardTemplate brain: few or no voxels outsideBrain
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_outsideBrain_BH ${atlas}_outsideBrain_BH -odt char
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_outsideBrain_LH ${atlas}_outsideBrain_LH -odt char
   fslmaths -dt float ${atlasFile} -bin -mul ${standardTemplate}_outsideBrain_RH ${atlas}_outsideBrain_RH -odt char

   #  inAtlas_BH/LH/RH:
   fslmaths -dt float ${atlasFile} -bin ${atlas}_inAtlas_BH -odt char
   fslmaths -dt float ${atlas}_inAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${atlas}_inAtlas_LH -odt char
   fslmaths -dt float ${atlas}_inAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${atlas}_inAtlas_RH -odt char
   #  outsideAtlas_BH/LH/RH:
   fslmaths -dt float ${atlas}_inAtlas_BH -sub 1 -abs ${atlas}_outsideAtlas_BH -odt char
   fslmaths -dt float ${atlas}_outsideAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${atlas}_outsideAtlas_LH -odt char
   fslmaths -dt float ${atlas}_outsideAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${atlas}_outsideAtlas_RH -odt char
   #  inBrainNotAtlas_BH/LH/RH (LH and RH are likely to be reported ROIs)
   fslmaths -dt float ${standardTemplate}_inBrain_BH -sub ${atlas}_inAtlas_BH -thr 0 ${atlas}_inBrainNotAtlas_BH -odt char
   fslmaths -dt float ${atlas}_inBrainNotAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_LH ${atlas}_inBrainNotAtlas_LH -odt char
   fslmaths -dt float ${atlas}_inBrainNotAtlas_BH -mul ${standardParent}/blockMasks/${standardTemplate}_blockMask_RH ${atlas}_inBrainNotAtlas_RH -odt char
   
   echo "...done."

   # Test that these masks are mutually exclusive and, as a group, exhaustive: resulting sum should only include 1s:
   # if includes values > 1 then may need to dilate brain mask
   # in comparing HarvardOxfordCort to 1mm MNI, there are 15607 atlas voxels outside of the brain, 664 voxels outside of brain when MNI -dilM, and 0 outside of brain when MNI -dilM -dilM
   #fslmaths -dt float ${atlas}_inBrain_BH -add ${atlas}_inBrainNotAtlas_BH -add ${atlas}_outsideBrain_BH ${atlas}_inExhaustive -odt char


# augment bilateral, left, and right atlass with bilateral space fillers (should have no zero-values when done)

   echo ""
   echo "Creating meaningful atlas labels to augment background areas in bilateral, LH, and RH divisions of ${atlasFile} ..."

   # BH:
   fslmaths -dt float ${atlas}_inBrainNotAtlas_BH -mul 254 -add ${atlasFile} ${atlas}_noZeros_BH -odt char
   # trim to standardTemplate brain edges before filling space outside the brain:
   fslmaths -dt float ${atlas}_noZeros_BH -mul ${standardTemplate}_inBrain_BH ${atlas}_noZeros_BH -odt char
   # fill space outside the brain:
   fslmaths -dt float ${standardTemplate}_outsideBrain_BH -mul 255 -add ${atlas}_noZeros_BH ${atlas}_noZeros_BH -odt char


   # LH:
   fslmaths -dt float ${atlas}_inBrainNotAtlas_RH -mul 252 -add ${atlas}_LH ${atlas}_noZeros_LH -odt char
   fslmaths -dt float ${atlas}_inBrainNotAtlas_LH -mul 250 -add ${atlas}_noZeros_LH ${atlas}_noZeros_LH -odt char
   # trim to standardTemplate brain edges before filling space outside the brain:
   fslmaths -dt float ${atlas}_noZeros_LH -mul ${standardTemplate}_inBrain_BH ${atlas}_noZeros_LH -odt char
   # fill space outside the brain:
   fslmaths -dt float ${standardTemplate}_outsideBrain_RH -mul 253 -add ${atlas}_noZeros_LH ${atlas}_noZeros_LH -odt char
   fslmaths -dt float ${standardTemplate}_outsideBrain_LH -mul 251 -add ${atlas}_noZeros_LH ${atlas}_noZeros_LH -odt char
   # add binary mask (flat) for contralateral inAtlas
   fslmaths -dt float ${atlas}_inAtlas_RH -bin -mul 249 -mul ${standardTemplate}_inBrain_BH -add ${atlas}_noZeros_LH ${atlas}_noZeros_LH -odt char

   # RH:
   fslmaths -dt float ${atlas}_inBrainNotAtlas_LH -mul 252 -add ${atlas}_RH ${atlas}_noZeros_RH -odt char
   fslmaths -dt float ${atlas}_inBrainNotAtlas_RH -mul 250 -add ${atlas}_noZeros_RH ${atlas}_noZeros_RH -odt char
   # trim to standardTemplate brain edges before filling space outside the brain:
   fslmaths -dt float ${atlas}_noZeros_RH -mul ${standardTemplate}_inBrain_BH ${atlas}_noZeros_RH -odt char
   # fill space outside the brain:
   fslmaths -dt float ${standardTemplate}_outsideBrain_LH -mul 253 -add ${atlas}_noZeros_RH ${atlas}_noZeros_RH -odt char
   fslmaths -dt float ${standardTemplate}_outsideBrain_RH -mul 251 -add ${atlas}_noZeros_RH ${atlas}_noZeros_RH -odt char
   # add binary mask (flat) for contralateral inAtlas
   fslmaths -dt float ${atlas}_inAtlas_LH -bin -mul 249 -mul ${standardTemplate}_inBrain_BH -add ${atlas}_noZeros_RH ${atlas}_noZeros_RH -odt char

   echo "...done."


echo ""
echo ""
echo "Range check: binary masks should have min and max of 0 and 1:"
echo ""
pwd
for file in ${standardTemplate}_* ${atlas}_* ${standardParent}/blockMasks/${standardTemplate}_blockMask_*; do 
   echo -n "${file} "
   fslstats ${file} -R; 
done
echo ""

echo ""
echo 'Volume check: should not see any crazy non-zero volumes, and ${atlas}_outsideBrain_?H vol should be small for cannonical atlases, but could be anythng for cluster-derived atlases'
echo ""
pwd
for file in ${standardTemplate}_* ${atlas}_* ${standardParent}/blockMasks/${standardTemplate}_blockMask_*; do echo -n  "${file} ";  fslstats ${file} -V | awk '{print $1}'; done
echo ""


echo ""
echo ""
echo "================================================================="
echo "FINISHED: augmented the input atlas/clusterMask with hemispheres and gross regions"
      date
echo "================================================================="
echo ""
echo ""

# ================================================================= #

echo ""
echo ""
echo "================================================================="
echo "START: split augmented atlas/clusterMask into regions for intersection volume calculations"
echo "(should take about 1 minute for every 5 ROIs)"
      date
echo "================================================================="
echo ""
echo ""

# split atlas into separate intensity regions. Regions will go into two subdirectories:
mkdir intensityOrig
mkdir intensityBin

# will be splitting based on a list of labels. Alter existing list or create that list if DNE:

if [ -s ${standardParent}/labels_${atlas}.txt ]; then
   # copy each line that does not match one of my reserved intensities
   while read line; do
      intensityPadded=`echo "${line}" | awk '{print $1}'`
      # get intensityPadded straight from file due to printf bug that screws up 008, 009, 018, 019, 038, 039, 048, ...
      #intensityPadded=`printf "%03d" ${intensity}`
      description=`echo "${line}" | awk '{print $2}'`
      # EDITME: range of reserved mask values below
      case "${intensityPadded}" in
         255)
            echo "" >> /dev/null
            ;;
         254)
            echo "" >> /dev/null
            ;;
         253)
            echo "" >> /dev/null
            ;;
         252)
            echo "" >> /dev/null
            ;;
         251)
            echo "" >> /dev/null
            ;;
         250)
            echo "" >> /dev/null
            ;;
         249)
            echo "" >> /dev/null
            ;;
         *)
            echo "${intensityPadded} ${description}" >> labels_${atlas}.txt
            ;;
       esac
   done < ${standardParent}/labels_${atlas}.txt
   # write a block with reserved intensities at bottom
   # EDITME: range of reserved mask intensities below
   # commented out block is full list for reference, and currently used adaptation of that list is below:

   #   echo "249 BACKGROUNDinAtlasButContralateral" >> labels_${atlas}.txt
   #   echo "250 BACKGROUNDinBrainIpsilateralButNotAtlas" >> labels_${atlas}.txt
   #   echo "251 BACKGROUNDoutsideBrainIpsilateral" >> labels_${atlas}.txt
   #   echo "252 BACKGROUNDinBrainContralateralButNotAtlas" >> labels_${atlas}.txt
   #   echo "253 BACKGROUNDoutsideBrainContralateral" >> labels_${atlas}.txt
   #   echo "254 BACKGROUNDinBrainButNotAtlas" >> labels_${atlas}.txt
   #   echo "255 BACKGROUNDoutsideBrain" >> labels_${atlas}.txt
   
   #echo "249 BACKGROUNDinAtlasButContralateral" >> labels_${atlas}.txt
   echo "250 BACKGROUNDinHemButNotAtlas" >> labels_${atlas}.txt
   echo "251 BACKGROUNDoutsideHemIpsilateral" >> labels_${atlas}.txt
   #echo "252 BACKGROUNDinBrainContralateralButNotAtlas" >> labels_${atlas}.txt
   #echo "253 BACKGROUNDoutsideBrainContralateral" >> labels_${atlas}.txt
   #echo "254 BACKGROUNDinBrainButNotAtlas" >> labels_${atlas}.txt
   #echo "255 BACKGROUNDoutsideBrain" >> labels_${atlas}.txt

else  # create a list from the values that exist in the mask

   # create list of values that exist in RH, LH, or both using AFNI's 3dhistog -uniq U.1D <input>, which outputs a one-column file U.1D
   for image in ${atlas}_noZeros_BH.nii.gz ${atlas}_noZeros_LH.nii.gz ${atlas}_noZeros_RH.nii.gz; do 
      3dhistog -unq histog_${image}.1D ${image} > /dev/null
   done
   cat histog_*.1D > histogAll.1D
   rm -f histog_*.1D
   # sort, get rid of duplicates, remove blank lines and lines starting wiht "#":
   sort -n histogAll.1D | uniq | sed '/^$/d' | sed '/^#/d' > histogAll_sorted.1D
   # zero-pad intensity values:
   while read line; do
      intensity=`echo "${line}" | awk '{print $1}'`
      intensityPadded=`printf "%03d" ${intensity}`
      # 251 and 250 are very likely to be reported...rest are dubious:
      # EDITME: range of reserved mask values below
      #case "${intensityPadded}" in
      #   255)
      #      echo "${intensityPadded} BACKGROUNDoutsideBrain" >> labels_${atlas}.txt
      #      ;;
      #   254)
      #      echo "${intensityPadded} BACKGROUNDinBrainButNotAtlas" >> labels_${atlas}.txt
      #      ;;
      #   253)
      #      echo "${intensityPadded} BACKGROUNDoutsideBrainContralateral" >> labels_${atlas}.txt
      #      ;;
      #   252)
      #      echo "${intensityPadded} BACKGROUNDinBrainContralateralButNotAtlas" >> labels_${atlas}.txt
      #      ;;
      #   251)
      #      echo "${intensityPadded} BACKGROUNDoutsideBrainIpsilateral" >> labels_${atlas}.txt
      #      ;;
      #   250)
      #      echo "${intensityPadded} BACKGROUNDinBrainIpsilateralButNotAtlas" >> labels_${atlas}.txt
      #      ;;
      #   249)
      #      echo "${intensityPadded} BACKGROUNDinAtlasButContralateral" >> labels_${atlas}.txt
      #      ;;
      #   *)
      #      echo "${intensityPadded} clusterValue${intensityPadded}" >> labels_${atlas}.txt
      #      ;;
      # esac
      case "${intensityPadded}" in
         255)
            echo "" > /dev/null
            ;;
         254)
            echo "" > /dev/null
            ;;
         253)
            echo "" > /dev/null
            ;;
         252)
            echo "" > /dev/null
            ;;
         251)
            echo "${intensityPadded} BACKGROUNDoutsideHemIpsilateral" >> labels_${atlas}.txt
            ;;
         250)
            echo "${intensityPadded} BACKGROUNDinHemButNotAtlas" >> labels_${atlas}.txt
            ;;
         249)
            echo "" > /dev/null
            ;;
         *)
            echo "${intensityPadded} clusterValue${intensityPadded}" >> labels_${atlas}.txt
            ;;
       esac
   done < histogAll_sorted.1D
   rm histogAll_sorted.1D
fi

# split and name the regions according to the labels_${atlas}.txt 

   echo "Splitting augmented ${atlas}_noZeros_?H into their compartments per labels_${atlas}.txt: ...."
   echo ""
   cat labels_${atlas}.txt
   echo ""
   while read line; do 
      intensity=`echo "${line}" | awk '{print $1}' `
      description=`echo "${line}" | awk '{print $2}' `
      #echo $intensity $description
      #create for BH LH and RH in both intensityOrig and intensityBin directories:
      for hem in BH LH RH ; do
         fslmaths -dt float ${atlas}_noZeros_${hem} -uthr ${intensity} -thr ${intensity}      intensityOrig/_${atlas}+${intensity}-${description}_${hem} -odt char
         fslmaths -dt float ${atlas}_noZeros_${hem} -uthr ${intensity} -thr ${intensity} -bin  intensityBin/_${atlas}+${intensity}-${description}_${hem} -odt char
         ls -1 intensityOrig/_${atlas}+${intensity}-${description}_${hem}*
         #DEBUG nonzeroMean=`fslstats intensityOrig/_${atlas}+${intensity}-${description}_${hem} -M`
         #DEBUG nonzeroVol=`fslstats intensityOrig/_${atlas}+${intensity}-${description}_${hem} -V | awk '{print $1}'`
         #DEBUG echo "${outputDir}/intensityOrig/_${atlas}+${intensity}-${description}_${hem} nonzeroMean=${nonzeroMean} nonzeroVol=${nonzeroVol}"
         #DEBUG echo "DEBUG: ${outputdir}/intensityBin/_${atlas}+${intensity}-${description}_${hem} `fslstats intensityBin/_${atlas}+${intensity}-${description}_${hem} -R`"
         #DEBUG echo "intensityOrig/_${atlas}+${intensity}-${description}_${hem} nonzeroMean=${nonzeroMean} nonzeroVol=${nonzeroVol}"
      done
      echo ""
   done < labels_${atlas}.txt


echo ""
echo ""
echo "================================================================="
echo "FINISHED: split augmented atlas/clusterMask into regions for intersection volume calculations"
      date
echo "================================================================="
echo ""
echo ""



# ------------------------- FINISHED: body of program ------------------------- #


# ------------------------- START: say bye and restore environment ------------------------- #
echo ""
echo "#################################################################"
echo "FINISHED: \"$ ${scriptName} ${1} ${2}\""
      date
echo "#################################################################"
echo ""
echo ""
echo ""
cd "${startDir}"
#export FSLOUTPUTTYPE=${FSLOUTPUTTYPEorig}
# ------------------------- END: say bye and restore environment ------------------------- #

