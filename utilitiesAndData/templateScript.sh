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

fxnPrintUsage() { 										#EDITME: customize for each script   
   echo >&2 "$0 - a script to do something"
   echo >&2 "Usage: $0 [-s] [-g ] [-p] [-c] {subjectID1 subjectID2 ...}"
   echo >&2 "  -s   screen input files"
   echo >&2 "  -g   gather input files"
   echo >&2 "  -p   process input files into 1mmMNI152-registered cluster maps"
   echo >&2 "  -c   generate cluster reports"
   echo >&2 "Each (optional) subjectID is in form \"sNNN\" (no quotes), and if none are provided on commandline then blindList in the script is used"
}


fxnTestBlindFormat() {
        # does blind start with required prefix? (as in: the stuff before the number part of the blind)
        requiredPrefix=s                                        				# EDITME: will probably change per study
        providedPrefix="`echo $1 | cut -b 1`"                   				# EDITME: number of positions to cut (for inclusion in $providedPrefix) would also differ per study
        echo "DEBUG: requiredPrefix and providedPrefix: $requiredPrefix $providedPrefix"
        if [ "${requiredPrefix}" != "${providedPrefix}" ]; then
                echo "DEBUG: wrong prefix"
                return 1
        fi
        # does blind have the right number of places (digits) following the prefix?
        requiredPlaces=3                                                        		# EDITME: will probably change per study
        providedPlaces="`echo -n $1 | sed 's/^.//' | xargs echo -n | wc -m`"            	# EDITME: number of prefix positions to remove with sed would also differ per study
        echo "DEBUG: requiredPlaces and providedPlaces: $requiredPlaces $providedPlaces"
        if [ "${requiredPlaces}" != "${providedPlaces}" ]; then
                echo "DEBUG: wrong number of digits"
                return 1
        fi
}


fxnParseBlindList() {
        if [ -z "`echo $@`" ]; then                             				#...if no blinds were supplied on the commandline, then:
                # EDITME: blindList formatted per original filename schema, poorly padded:
                blindListUgly="s01 s02 s03 s04 s06 s07 s08 s09 s10 s11 s12 s13 s14 s15 s16 s101 s102 s103 s104 s105 s106 s107 s108 s109 s110 s112 s113 s114 s115 s116 s201 s202 s203 s204 s206 s207 s208 s209 s210 s211 s212 s213 s214 s215 s216 s217"
                # EDITME: blindList reformatted for three digits, correctly padded:
                blindList000="s001 s002 s003 s004 s006 s007 s008 s009 s010 s011 s012 s013 s014 s015 s016 s101 s102 s103 s104 s105 s106 s107 s108 s109 s110 s112 s113 s114 s115 s116 s201 s202 s203 s204 s206 s207 s208 s209 s210 s211 s212 s213 s214 s215 s216"
                echo ""
                echo ""
                echo "No subjectIDs entered on commandline, so proceeding with list defined in the script: ${blindList}"
                echo ""
                echo "DEBUG: ok? (return or ctrl-c)" && read

        else                                                    				#...else blinds were supplied on the commandline and need to be checked:
                blindListUgly=""
                blindList=""
                for enteredBlind in $@; do
                        echo "DEBUG: enteredBlind=${enteredBlind}"
                        fxnTestBlindFormat "${enteredBlind}"
                        if [ $? -ne 0 ]; then
                                blindListUgly="${blindListUgly} ${enteredBlind}"		# ...send bad blinds to $blindListUgly list
                        else
                                blindList="${blindList} ${enteredBlind}"			# ...send good blinds to $blindList
                        fi
                done
                if [ ! -z "`echo ${blindListUgly}`"  ]; then        				#...if there were poorly formatted blinds entered on commandline, inform user and exit. Other times hese will    
                        echo ""
                        echo ""
                        echo "ERROR: incorrectly formated subjectIDs (see usage note below): ${blindListUgly}"
                        echo ""
                        fxnPrintUsage
                        echo ""
                        exit 1
                fi
        fi
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
if [ $# -lt 1 ] ; then
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi

# EDITME: initialization of variables that receive values during getopt argument processing:
screen=0
gather=0
process=0
generateClusterReport=0
requiredfile=""

# EDITME: argument processing with getopt:
# (...don't forget the additional shift in the case statement if assigning argument $2)
set -- `getopt sgpcf: "$@"`
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
      -f)   requiredfile="${2}"; shift
            ;;
      --)	shift; break
            ;;
      -*)
            echo >&2 "usage: $0 a short usage note"
             exit 1
             ;;
       *)	break
            ;;		# terminate while loop
    esac
    shift
done
#echo "DEBUG: remainder arguments after getopt: $@" && echo "(return to continue, ctrl-c to exit)" && read
#fxnParseBlindList $@

# EDITME: check for options that absolutely must be included:
if [ -z ${requiredfile} ]; then
   echo ""
   echo "ERROR: must supply requiredfile"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi
 
# EDITME: check for incompatible invocation options:
if [ "$headingsoff" != "0" ] && [ "$headingsonly" != "0" ] ; then
   echo ""
   echo "ERROR: cannot specify both -r and -n:"
   echo ""
   fxnPrintUsage
   echo ""
   exit 1
fi

# EDITME: check for malformed or nonexistent input:
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
# if indicated, screen some images (usually input images)
if [ $screen -eq 1 ]; then
fi

# ================================================================= #
# if indicated, gather some images (usually input images, fixing in process)
if [ $gather -eq 1 ]; then
fi

# ================================================================= #
# if indicated, process or preprocess some images
if [ $process -eq 1 ]; then
fi

# ================================================================= #
# if indicated, generate some cluster reports
if [ $generateClusterReport -eq 1 ]; then
fi


echo ""
echo ""
echo "================================================================="
echo "START: do some stuff"
echo "(should take about TBD minutes)"
      date
echo "================================================================="
echo ""
echo ""

#do some stuff

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



