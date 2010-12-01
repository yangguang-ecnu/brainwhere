#!/bin/sh
#
# LOCATION: 	<location including filename>
# CALL AS:	<usage note or "see invocation section in program body">
#
# CREATED:	<date> by <whom>
# LAST UPDATED:	<date> by <whom>
#
# DESCRIPTION:
# <description of what the script does>
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


# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"


# second: basic system resources:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`		# ...assign a constant if not calling from a script
scriptPID="$$"				# ...assign a constant if not calling from a script
#scriptDir=""				# ...used to get to other scripts in same directory
scriptUser=`whoami`			# ...used in file and dir names
startDate=`date +%Y%m%d` 		# ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`	# ...used in file and dir names
#cdMountPoint


# third: variables for filesystem locations, filenames, long arguments, etc.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
intensity="t1bfc0"			# ...to be used in file and folder names
orientation="radOrig"			# ...ditto


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
# EDITME: changer per system
#tempParent=/Users/stowler/temp
tempParent=/tmp

# ${tempDir}:
# dir where temp files for individual processing runs can be stored
# e.g. tempDir="${tempRoot}/${currentDateTime}-from_${scriptName}.${scriptPID}"
tempDir="${tempParent}/${currentDateTime}-from_${scriptName}.${scriptPID}"

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


# ------------------------- START: check invocation ------------------------- #
#if [ $# != 1 ]; then
#	echo ""
#	echo "please call as bfc_comparison.sh <ucr2blindNum>"
#	echo ""
#	exit
#fi
# ------------------------- FINISHED: check invocation ------------------------- #


# ------------------------- START: say hi ------------------------- #
#echo ""
#echo ""
#echo "#################################################################"
#echo "START: \"${scriptName} ${1}\""
#      date
#echo "#################################################################"
#echo ""
#echo ""



# ------------------------- FINISHED: say hi ------------------------- #


# ------------------------- START: body of program ------------------------- #

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


mkdir ${tempDir}

fileLeftOrig="$1"
fileRightOrig="$2"
blankFiller="$3"

# remove blank lines:
fileLeftClean="${tempDir}/fileLeftClean.txt"
fileRightClean="${tempDir}/fileRightClean.txt"
cat "${fileLeftOrig}" | sed '/^$/d' >> "${fileLeftClean}"
cat "${fileRightOrig}" | sed '/^$/d' >> "${fileRightClean}"
# DEBUG:
#ls -l ${tempDir}/*

fileLeftCleanLineCount=`wc -l "${fileLeftClean}" | awk '{print $1}'`
fileRightCleanLineCount=`wc -l "${fileRightClean}" | awk '{print $1}'`
#echo "DEBUG: fileLeftCleanLineCount fileRightCleanLineCount = $fileLeftCleanLineCount $fileRightCleanLineCount"

# if fileLeftClean longer than fileRightClean, then longerFile="left", else longerFile="right" 

if [ $fileLeftCleanLineCount -gt $fileRightCleanLineCount ]; then
   longerFileID="left"
   longerFileClean="${fileLeftClean}"
   longerFileCleanLineCount=${fileLeftCleanLineCount}
   shorterFileID="right"
   shorterFileClean="${fileRightClean}"
   shorterFileCleanLineCount="${fileRightCleanLineCount}"
else
   longerFileID="right"
   longerFileClean="${fileRightClean}"
   longerFileCleanLineCount="${fileRightCleanLineCount}"
   shorterFileID="left"
   shorterFileClean="${fileLeftClean}"
   shorterFileCleanLineCount="${fileLeftCleanLineCount}"
fi
#echo "DEBUG: longerFileID=${longerFileID}"



for longerCounter in `seq 1 $longerFileCleanLineCount`; do
   #echo "DEBUG: longerCounter=${longerCounter}"
   #echo "DEBUG: longerFileClean = ${longerFileClean}"
   longerFileField=`cat ${longerFileClean} | sed -n -e "${longerCounter}p"`
   #echo "DEBUG: longerFileField = ${longerFileField}"
   if [ ${longerCounter} -gt ${shorterFileCleanLineCount} ]; then
      # TBD: below five-in-a-row blankFiller is temporary and due to need in cluster report (four extra columns: minInt, maxInt, minIntXYZ, and maxIntXYZ)
      shorterFileField="${blankFiller} ${blankFiller} ${blankFiller} ${blankFiller} ${blankFiller}"
   else
      shorterFileField=`cat ${shorterFileClean} | sed -n -e "${longerCounter}p"`
   fi

   if [ ${longerFileID} = "left" ]; then
      echo "${longerFileField} ${shorterFileField}" >> ${tempDir}/unformattedOutput.txt
   else
      echo "${shorterFileField} ${longerFileField}" >> ${tempDir}/unformattedOutput.txt
   fi
done

column -t ${tempDir}/unformattedOutput.txt


#echo ""
#echo ""
#echo "================================================================="
#echo "FINISHED: did some stuff "
#      date
#echo "================================================================="
#echo ""
#echo ""

# ================================================================= #

#echo ""
#echo ""
#echo "================================================================="
#echo "START: do some other stuff"
#echo "(should take about TBD minutes)"
#      date
#echo "================================================================="
#echo ""
#echo ""

# doing other stuff....

#echo ""
#echo ""
#echo "================================================================="
#echo "FINISHED: did some other stuff "
#      date
#echo "================================================================="
#echo ""
#echo ""



# ------------------------- FINISHED: body of program ------------------------- #


# ------------------------- START: say bye and restore environment ------------------------- #
#echo ""
#echo "#################################################################"
#echo "FINISHED: \"${scriptName} ${1}\""
#      date
#echo "#################################################################"
#echo ""
#echo ""
#echo ""
#export FSLOUTPUTTYPE=${FSLOUTPUTTYPEorig}
# ------------------------- END: say bye and restore environment ------------------------- #

