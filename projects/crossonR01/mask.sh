#!/bin/sh
for file in /data/birc/RESEARCH/RO1/SUBJECTS/INT2/towlerGamma12omniTest/INT2_*/*/afnifiles/INT2_*_*_max.buck_irfcorr5.thresh10.gammaThresh8.warped1mmMNI152nii.gz.nii.gz; do
 #ls -al $file
 parentName=`dirname $file`
 echo "$parentName"
 fileName=`basename $file`
 echo "$fileName"
 MNImask=/data/pkgs/fsl-4.1.6-centos5_64/data/standard/MNI152_T1_1mm_brain_mask.nii.gz

 3dcalc -a $file -b $MNImask -expr 'a*b' -prefix ${parentName}/${fileName}_masked

done	
