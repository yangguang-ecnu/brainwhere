#!/bin/sh
#
# LOCATION: 	   <location including filename>
# USAGE:          (see fxnPrintUsage() function below)
#
# CREATED:	   201008?? by stowler@gmail.com
# LAST UPDATED:	   20101005 by stowler@gmail.com
#
# DESCRIPTION:
# Registers T1 to the 1mm MNI152 template, along with optional lesion mask deweighting and application of transform to EPI
# 
# STYSTEM REQUIREMENTS:
#  - afni, fsl
#  - getopt must be installed
#  - awk must be installed for fxnCalc
#  - ~stowler/scripts/stowler-checkImageBasics.sh
#
# INPUT FILES AND PERMISSIONS:
# <list or describe>
#
# OTHER ASSUMPTIONS:
# <list or describe>
#
#
# TBD: accept HEAD/BRIK also
# TBD: accept multiple epi-aligned images?
# TBD: add converstion to RPI

# ------------------------- START: fxn definitions ------------------------- #

fxnPrintUsage() {
   #EDITME: customize for each script:
   echo >&2 "$0 - a script to register unstriped T1, lesion mask, and epi to 1mmMNI152 space"
   echo >&2 "Usage: stowler-registerTo1mmMNI152 \\"
   echo >&2 "  -s <subjectID>        \\"
   echo >&2 "  -t <t1.nii>           \\"
   echo >&2 "  -o <FullPathToOutdir> \\"
   echo >&2 "[ -l <lesion.nii> ]     \\"
   echo >&2 "[ -e <epi.nii> ]     \\"
   echo >&2 "[ -b <buck.nii> ] "
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
#cdMountPoint
bwDir="/Users/stowler/brainwhere"
source ${bwDir}/utilities/brainwhereCommonFunctions.sh

# ------------------------- FINISHED: definitions and constants ------------------------- #



# ------------------------- START: invocation ------------------------- #

# check for number of arguments
if [ $# -lt 1 ] ; then
   echo ""
   echo "ERROR: no files specified"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi

#initialization of variables that receive values during argument processing
blind=""
t1=""
outDir=""
lesion=""
epi=""
buck=""

# argument processing with getopt:
set -- `getopt s:t:o:l:e: "$@"`
[ $# -lt 1 ] && exit 1	# getopt failed
while [ $# -gt 0 ]; do
    case "$1" in
      -s)   blind="${2}"; shift ;;
      -t)   t1="${2}"; shift ;;
      -o)   outDir="${2}"; shift ;;
      -l)   lesion="${2}"; shift ;;
      -e)   epi="${2}"; shift ;;
      -b)   buck="${2}"; shift ;;
      --)   shift; break ;;
      -*)   echo >&2 "usage: $0 - a short usage note "; exit 1 ;;
       *)   break ;; # terminate while loop
    esac
    shift
done

# Are we missing any required invocation options? Checking:
if [ -z ${blind} ]; then
	echo ""
	echo "ERROR: must supply subjectID"
	echo ""
	fxnPrintUsage
	echo ""
	exit 1
elif [ -z ${t1} ]; then
	echo ""
	echo "ERROR: must supply T1"
	echo ""
	fxnPrintUsage
	echo ""
	exit 1
elif [ -z ${outDir} ]; then
	echo ""
	echo "ERROR: must supply full path to outputDirectory"
	echo ""
	fxnPrintUsage
	echo ""
	exit 1
fi

# check for bad or nonexistent images :
fxnValidateImages ${t1}
if [ $? -eq 1 ]; then 
	echo ""
	echo "ERROR: $t1 is not a valid image"
	echo ""
	fxnPrintUsage
	echo ""
	exit 1
fi

if [ ! -z ${lesion} ]; then
	fxnValidateImages ${lesion}
fi

if [ ! -z ${epi} ]; then
	fxnValidateImages ${epi}
fi

if [ ! -z ${buck} ]; then
	fxnValidateImages ${buck}
fi

# ------------------------- FINISHED: invocation ------------------------- #



# ------------------------- START: say hi ------------------------- #
echo ""
echo ""
echo "#################################################################"
echo "START: \"${scriptName} $@\""
      date
echo "#################################################################"
echo ""
echo ""
# ------------------------- FINISHED: say hi ------------------------- #



# ------------------------- START: body of program ------------------------- #

fxnSetTempDir                 # setup and create $tempDir if necessary
# TBD: Verify that destination directories exist and are user-writable:

echo ""
echo ""
echo "================================================================="
echo "START: nonlinear registration of ${blind} to 1mmMNI152"
echo "(about 20 minutes, or about 60 minutes if also applying warp to epi)"
      date
echo "================================================================="
echo ""
echo ""


# ================================================================= #
# display input image metadata:
echo "Images to nonlinear register into 1mmMNI152 (note: a lesion should match T1's geometry):"
echo ""
sh ${bwDir}/displayImageGeometry.sh -n ${t1} >> ${tempDir}/inputUnformatted.txt
for image in $t1 $lesion $epi $buck; do
	if [ -s $image ]; then
		sh ${bwDir}/displayImageGeometry.sh -r $image >> ${tempDir}/inputUnformatted.txt
	fi
done
cat ${tempDir}/inputUnformatted.txt | column -t
echo ""
echo "DEBUG: Happy? (Return to continue, ctrl-c to exit)"
read

# ================================================================= #
# copy images to $tempDir:
echo ""
echo "Copying input images to ensure consistent naming and avoid bad datatypes:"
# TBD: maybe 3dresample to RPI here instead of imcp
#imcp $t1 ${tempDir}/${blind}_t1
3dresample \
	-orient rpi \
	-prefix ${tempDir}/${blind}_t1.nii.gz \
	-inset $t1
ls -1 ${tempDir}/${blind}_t1*
if [ -s "`echo ${lesion}`" ]; then
	fslmaths ${lesion} ${tempDir}/${blind}_lesion -odt char
	ls -1 ${tempDir}/${blind}_lesion*
fi
if [ -s "`echo ${epi}`" ]; then
	# imcp ${epi} ${tempDir}/${blind}_epi
	3dresample \
        -orient rpi \
        -prefix ${tempDir}/${blind}_epi.nii.gz \
        -inset ${epi}
	ls -1 ${tempDir}/${blind}_epi*
fi
if [ -s "`echo ${buck}`" ]; then
	imcp ${buck} ${tempDir}/${blind}_buck
	ls -1 ${tempDir}/${blind}_buck*
fi


# ================================================================= #
# skull-strip T1:
echo ""
echo ""
echo "Skull-striping T1..."
echo ""
bet ${tempDir}/${blind}_t1 ${tempDir}/${blind}_t1_brain -R -v
echo ""
echo "...done:"
ls -l ${tempDir}/${blind}_t1_brain*
echo ""
echo ""



# ================================================================= #
# if lesion mask is being used, invert intensities so 1's are outside of lesion:
if [ -s "`echo ${lesion}`" ]; then
	echo ""
	echo ""
	echo "Inverting lesion mask..."
	fslmaths ${tempDir}/${blind}_lesion -sub 1 -abs ${tempDir}/${blind}_lesionInverted -odt char
	echo "...done:"
	ls -l ${tempDir}/${blind}_lesionInverted*
fi



# ================================================================= #
# linear registration of t1_brain to template:
echo ""
echo ""
echo "Linear transformation of T1 takes about two minutes..."
# include -inweight if we have a lesion, don't if we don't: 
if [ -s "`echo ${lesion}`" ]; then
	flirt \
	     -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
	     -in ${tempDir}/${blind}_t1_brain \
	     -inweight ${tempDir}/${blind}_lesionInverted \
	     -omat ${tempDir}/${blind}_affine_transf.mat 
else
	flirt \
	     -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
	     -in ${tempDir}/${blind}_t1_brain \
	     -omat ${tempDir}/${blind}_affine_transf.mat 
fi
echo "...done:"
ls -l ${tempDir}/${blind}_affine_transf.mat



# ================================================================= #
# if epi is to be registered, here's linear registration of epi to t1_brain:
if [ -s "`echo ${epi}`" ]; then
	echo ""
	echo ""
	echo "Linear transformation of EPI takes about two minutes..."
	flirt \
	-ref ${tempDir}/${blind}_t1_brain \
	-in ${tempDir}/${blind}_epi \
	-dof 7 \
	-omat ${tempDir}/${blind}_funct2struct.mat
	echo "...done:"
	ls -l ${tempDir}/${blind}_funct2struct.mat
	echo ""
	echo ""
fi



# ================================================================= #
# calculation of nonlinear t1->mni transformation:
echo ""
echo ""
echo "nonlinear transformation takes about 15 minutes..."
echo "(ignore messages about requested tolerance...unless your transformation turns out horrible, in which case they may have been meaningful)"
echo ""
# include -inmask if we have a lesion, don't if we don't: 
if [ -s "`echo ${lesion}`" ]; then
	fnirt \
	     --in=${tempDir}/${blind}_t1 \
	     --aff=${tempDir}/${blind}_affine_transf.mat \
	     --cout=${tempDir}/${blind}_nonlinear_transf \
	     --config=T1_2_MNI152_2mm \
	     --inmask=${tempDir}/${blind}_lesionInverted 
else
	fnirt \
	     --in=${tempDir}/${blind}_t1 \
	     --aff=${tempDir}/${blind}_affine_transf.mat \
	     --cout=${tempDir}/${blind}_nonlinear_transf \
	     --config=T1_2_MNI152_2mm 
fi
echo ""
echo "...done:"
ls -l ${tempDir}/${blind}_nonlinear_transf*



# ================================================================= #
# apply nonlinear transformations :

echo ""
echo ""
echo "applying nonlinear warp to T1 (about 1 minute)..."
applywarp \
     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
     --in=${tempDir}/${blind}_t1 \
     --warp=${tempDir}/${blind}_nonlinear_transf \
     --out=${tempDir}/${blind}_t1_warped
ls -l ${tempDir}/${blind}_t1_warped*

echo ""
echo ""
echo "applying nonlinear warp to skull-striped T1 (about 1 minute)..."
applywarp \
     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
     --in=${tempDir}/${blind}_t1_brain \
     --warp=${tempDir}/${blind}_nonlinear_transf \
     --out=${tempDir}/${blind}_t1_brain_warped
ls -l ${tempDir}/${blind}_t1_brain_warped*

if [ -s "`echo ${lesion}`" ]; then
	echo ""
	echo ""
	echo "applying nonlinear warp to lesion (about 1 minute)..."
	applywarp \
	     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
	     --in=${tempDir}/${blind}_lesion \
	     --warp=${tempDir}/${blind}_nonlinear_transf \
	     --out=${tempDir}/${blind}_lesion_warped \
	     --interp=nn
	ls -l ${tempDir}/${blind}_lesion_warped*
fi

if [ -s "`echo ${epi}`" ]; then
	echo ""
	echo ""
	echo "applying nonlinear warp to epi (about 30 minutes)..."
	ls -l ${tempDir}/${blind}_epi*
	#applywarp \
	#     --ref=${FSLDIR}/data/standard/MNI152_T1_1mm \
	#     --in=${tempDir}/${blind}_epi \
	#     --warp=${tempDir}/${blind}_nonlinear_transf \
	#     --premat=${tempDir}/${blind}_funct2struct.mat \
	#     --out=${tempDir}/${blind}_epi_warped
	applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_1mm --in=${tempDir}/${blind}_epi --warp=${tempDir}/${blind}_nonlinear_transf --premat=${tempDir}/${blind}_funct2struct.mat --out=${tempDir}/${blind}_epi_warped

	ls -l ${tempDir}/${blind}_epi_warped*
fi


echo ""
echo ""
echo "================================================================="
echo "FINISHED: nonlinear registration of ${blind} to 1mmMNI152 "
      date
echo "================================================================="
echo ""
echo ""

cp ${tempDir}/*.nii.gz ${outDir}/
cp ${tempDir}/*.nii ${outDir}/
cp ${tempDir}/*.mat ${outDir}/

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
#
## doing other stuff....
#
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

rm -f ${tempDir}/inputUnformatted.txt
rm -fr ${tempDir}
#echo ${tempDir}
#ls -ltr ${tempDir}
echo ""
echo ""
echo ${outDir}
ls -ltr ${outDir}

echo ""
echo "#################################################################"
echo "FINISHED: \"${scriptName} $@\""
      date
echo "#################################################################"
echo ""
echo ""
echo ""
export FSLOUTPUTTYPE=${FSLOUTPUTTYPEorig}

# ------------------------- END: say bye and restore environment ------------------------- #



