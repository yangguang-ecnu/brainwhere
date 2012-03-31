#!/bin/sh

# get study-related variables, including blind numbers:
source ${bwDir}/projects/crossonR01/r01-environment.sh


# print one line of column headers for import to existing R scripts
# echo "participant,group,session,roi,ulLeft,ulRight"

# this triple loop extracts left and right ul volumes for each blindXsessionXroi combo:
#for blind in `echo ${intentionBlinds} ${controlBlinds}`; do
#   for session in pre post 3mo; do
#      #for roi in CROSSONlateralFrontalROI CROSSONPerisylvian CROSSONmedialFrontal; do
#      for roi in CROSSONremainingLatFrontal CROSSONifg CROSSONlatMotor; do
#         clusterReportFile="${parentDir}/${blind}/${session}/afnifiles/"
#         ulLeft=`grep ^.....${roi} ${clusterReportFile} | awk '{print $5}'`
#         ulRight=`grep ^.....${roi} ${clusterReportFile} | awk '{print $6}'`
#         # assign group label for line, allowing that user accidentally assigned blind to multiple groups
#         group=""
#         if grep -q ${blind} <<<${intentionBlinds}; then group="intention"; fi
#         if grep -q ${blind} <<<${controlBlinds}; then group="${group}control"; fi
#         if [ -z ${group} ]; then group="other"; fi
#         echo "${blind},${group},${session},${roi},${ulLeft},${ulRight}" 
#      done
#   done
#done

# treatment group:
fslmaths \
/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s01/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s03/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s05/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s06/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s11/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s12/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s15/pre/afnifiles/*pre_lesion_warped.nii.gz \
/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/lesionOverlap_treatment.nii.gz \
-odt char

# control group:
fslmaths \
/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s04/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s07/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s08/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s10/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s14/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s16/pre/afnifiles/*pre_lesion_warped.nii.gz \
-add /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_s19/pre/afnifiles/*pre_lesion_warped.nii.gz \
/data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/lesionOverlap_control.nii.gz \
-odt char

echo ""
echo ""
ls -al /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/lesionOverlap_*.nii.gz
echo ""
echo ""
