#!/bin/sh
#
# LOCATION: 	   <location including filename>
# USAGE:          (see fxnPrintUsage() function below)
#
# CREATED:	      <date> by <whom>
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
#
# CONVENTIONS:
#    #EDITME 		- code that may need to be changed per application/host/study/etc
#    #TBD 		- "To Be Done" reminders to the author
#    echo "DEBUG: " 	- debugging statements: increasingly commented as a script matures


# ------------------------- START: fxn definitions ------------------------- #

## include pre-defined external functions:
#scriptParent=											#EDITME: parentDir of script may differ per system
#source ${scriptParent}/stowlerIncludesForMR.sh
source ${bwDir}/utilitiesAndData/brainwhereCommonFunctions.sh

fxnPrintUsage() { 										#EDITME: customize for each script   
   echo >&2 "$0 - a script to calculate K-S statitic across two 3D images, with an inclusion mask to indicate which voxels should be included."
   echo >&2 ""
   echo >&2 "Usage: imageKS.sh                                                               \\"
   echo >&2 "  -i <image 1 of 2 for K-S calculation>                                         \\"
   echo >&2 "  -i <image 2 of 2 for K-S calculation>                                         \\"
   echo >&2 "  -b <brain mask for image 1 (intensity 1 indicates brain, 0's outside brain)>  \\"
   echo >&2 "  -b <brain mask for image 2 >                                                  \\"
   echo >&2 "[ -m <mask containing non-zero voxels to ignore, e.g., cluster mask>            \\ ]"
   echo >&2 "[ -m <another mask containing non-zero voxels to ignoreareas to ignore>         \\ ]"
   echo >&2 ""
   echo >&2 "(specify as many -m files as you like, just prepend each of them with -m)"
}




# ------------------------- FINISHED: fxn definitions ------------------------- #



# ------------------------- START: definitions and constants ------------------------- #

# first: anything related to command-line arguments:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# e.g. firstArgumentValue="$1"


# second: basic system resources:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
scriptName=`basename $0`			# ...assign a constant here if not calling from a script
scriptPID="$$"					# ...assign a constant here if not calling from a script
#scriptDir=""					# ...used to get to other scripts in same directory
scriptUser=`whoami`				# ...used in file and dir names
startDate=`date +%Y%m%d`			# ...used in file and dir names
startDateTime=`date +%Y%m%d%H%M%S`		# ...used in file and dir names
#cdMountPoint

: <<'COMMENTBLOCK'
   # third: variables for filesystem locations, filenames, long arguments, etc.
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
   intensity="t1bfc0"			         # ...to be used in file and folder names
   orientation="radOrig"			      # ...ditto

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
COMMENTBLOCK

# ------------------------- FINISHED: definitions and constants ------------------------- #



# ------------------------- START: invocation ------------------------- #

# EDITME: check for number of arguments, which will vary:
if [ $# -lt 3 ] ; then
   echo ""
   echo "ERROR: too few arguments specified. See usage note:"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi

# EDITME: initialization of variables that receive values during getopt argument processing:
image1and2=""
brainMask1and2=""
masks=""

# EDITME: argument processing with getopt:
# (...don't forget the additional shift in the case statement if assigning argument $2)
set -- `getopt i:b:m: "$@"`
[ $# -lt 1 ] && exit 1	# getopt failed
while [ $# -gt 0 ]
do
    case "$1" in
      -i)   image1and2="${image1and2} ${2}"; shift ;;
      -b)   brainMask1and2="${brainMask1and2} ${2}"; shift ;;
      -m)   masks="${masks} ${2}"; shift ;;
      --)   shift; break ;;
      -*)   echo >&2 "usage: $0 TBD: a short usage note" exit 1 ;;
       *)   break ;;		# terminate while loop
    esac
    shift
done
#echo "DEBUG: remainder arguments after getopt: $@" && echo "(return to continue, ctrl-c to exit)" && read
#fxnParseBlindList $@

# EDITME: check for options that absolutely must be included:
if [ -z "${image1and2}" ]; then
   echo ""
   echo "ERROR: must supply the images you want to test"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi
if [ -z "${brainMask1and2}" ]; then
   echo ""
   echo "ERROR: must supply brain masks"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi
 
# EDITME: check for incompatible invocation options:
# if [ "$headingsoff" != "0" ] && [ "$headingsonly" != "0" ] ; then
#    echo ""
#    echo "ERROR: cannot specify both -r and -n:"
#    echo ""
#    fxnPrintUsage
#    echo ""
#    exit 1
# fi

# the following requires echo $var, not just $var for ws-sep'd values in $var to be subsequently read as multiple values instead of single value containing ws"
for image in `echo ${image1and2} ${brainMask1and2} ${masks}`; do
        #echo "DEBUG: return to validate integerVolume ${image}"
        #read
        if [ ! -z ${image} ]; then
                fxnValidateImages ${image}
                if [ $? -eq 1 ]; then
                        echo ""
                        echo "ERROR: $image is not a valid image"
                        echo ""
                        fxnPrintUsage
                        echo ""
                        exit 1
                #else
                #       echo "DEBUG $image is a valid image. Yay!"
                fi
        fi
done

# ------------------------- FINISHED: invocation ------------------------- #



# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"${scriptName} ${1}\""
      date
echo "#################################################################"
echo ""
echo ""
# ------------------------- FINISHED: say hi ------------------------- #



# ------------------------- START: body of program ------------------------- #

fxnSetTempDir            # setup and create $tempDir if necessary
#fxnValidateImages $@     # verify that all input images are actually images
# TBD: Verify that destination directories exist and are user-writable:

# ================================================================= #
# display input image metadata:
echo "Images specified on the command line must have matching geometry:"
echo ""
#sh ${bwDir}/displayImageGeometry.sh -n ${brainMask} >> ${tempDir}/inputUnformatted.txt
# the following requires echo $var, not just $var for ws-sep'd values in $var to be subsequently read as multiple values instead of single value containing ws:
for image in `echo ${image1and2} ${brainMask1and2} ${masks}`; do
        if [ -s $image ]; then
                sh ${bwDir}/displayImageGeometry.sh -r $image >> ${tempDir}/inputUnformatted.txt
        fi
done
cat ${tempDir}/inputUnformatted.txt | column -t
echo ""
echo "DEBUG: Happy? (Return to continue, ctrl-c to exit)"
read



echo ""
echo ""
echo "================================================================="
echo "START: extract intensity values from image1 and image2, calcualte K-S statistic"
echo "(should take about TBD minutes)"
      date
echo "================================================================="
echo ""
echo ""


imageCounter=1 

# split input file names and paths into their individual components:
# get first image file:
image1="`echo "${image1and2}" | awk '{print $1}'`"
# get second image file:
image2="`echo "${image1and2}" | awk '{print $2}'`"
# get first brian mask:
brainMask1="`echo "${brainMask1and2}" | awk '{print $1}'`"
# get second brian mask:
brainMask2="`echo "${brainMask1and2}" | awk '{print $2}'`"
#echo "DEBUG: Image1 is ${image1}"
#read


# get the intersection of brainMask1 and brainMask2
3dcalc -a ${brainMask1} -b ${brainMask2} -expr 'a*b' -prefix ${tempDir}/brainMaskIntersection
ls -al ${tempDir}/brainMaskIntersection*
read

# Dump first image, accounting for mask:
3dmaskdump -mask ${tempDir}/brainMaskIntersection+tlrc.HEAD -noijk -o ${tempDir}/intensityValues_image1_masked.txt ${image1}'[0]'

# Dump second image, accounting for mask:
3dmaskdump -mask ${tempDir}/brainMaskIntersection+tlrc.HEAD -noijk -o ${tempDir}/intensityValues_image2_masked.txt ${image2}'[0]'


echo ""
echo "DEBUG: listing the text files containing the dumped voxel intensities:"
echo ""
ls -al ${tempDir}/intensityValues_image?_masked.txt
echo ""
echo "(ENTER to continue, CTRL-C to cancel)"
read


# compare brain-masked intensity distributions with ks.test():
#print(as.numeric(image1masked))
#print(as.numeric(image2masked))

# the " - " following Rscript below indicates that R commands will come from standard in
Rscript - ${tempDir}/intensityValues_image1_masked.txt ${tempDir}/intensityValues_image2_masked.txt <<RSCRIPT
	args <- commandArgs(TRUE)
	#str(args)
	#summary(args)
	#head(args)
	image1masked <- scan(args[1])
	image2masked <- scan(args[2])

	# DEBUGGING:
	writeLines("")
	writeLines("--------------DEBUG START--------------")
	writeLines("")
	head(image1masked)
	str(image1masked)
	summary(image1masked)
	head(image2masked)
	str(image2masked)
	summary(image2masked)
	writeLines("")
	writeLines("--------------DEBUG END--------------")
	writeLines("")
	writeLines("")
	writeLines("--------------K-S results (minding our violoation of K-S iid assumption)--------------")
	writeLines("H0: image 1 and image 2 intensities are drawn from equivalent distributions")
	writeLines("HA: image 1 and image 2 intensities are not drawn from equivalent distributions")
	writeLines("    (e.g., the voxels in image 1 and image 2 may have been dimage 1 and image 2 intensities are not drawn from equivalent distributions")
	writeLines("")
	ks.test(image1masked, image2masked, alternative=c("two.sided"), exact=NULL)
	require(graphics)
	#plot(ecdf(image1masked), xlim=range(c(image1masked, image2masked)))
	#plot(ecdf(image2masked), add=TRUE, lty="dashed")
	require(ggplot2)
	#qplot(unique(image1masked), ecdf(image1masked)(unique(image1masked))*length(image1masked), geom='step')
	#qplot(unique(image2masked), ecdf(image2masked)(unique(image2masked))*length(image2masked), geom='step')
RSCRIPT


echo ""
echo ""
echo "================================================================="
echo "FINISHED: did some stuff "
      date
echo "================================================================="
echo ""
echo ""

# ================================================================= #

# echo ""
# echo ""
# echo "================================================================="
# echo "START: do some other stuff"
# echo "(should take about TBD minutes)"
#       date
# echo "================================================================="
# echo ""
# echo ""
# 
# # doing other stuff....
# 
# echo ""
# echo ""
# echo "================================================================="
# echo "FINISHED: did some other stuff "
#       date
# echo "================================================================="
# echo ""
# echo ""

# ------------------------- FINISHED: body of program ------------------------- #


# ------------------------- START: say bye and restore environment ------------------------- #

# echo "" && echo "" && echo "${tempDir}" && ls -ltr ${tempDir}
# echo "" && echo "" && echo "${outDir}"  && ls -ltr ${outDir}
rm -fr ${tempDir}

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



