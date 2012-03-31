#!/bin/sh
#
# Per Dana's email, these three registrations don't work in a variety of ways:
# 
# registerTo1mmMNI152.sh \
# -s PAS07-1 \
# -t /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2.3Danat_orig.nii.gz \
# -o /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Register_bet \
# -l /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1_Lesionmask.nii.gz \
# -e /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.epi01_bet.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_READ_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_REPEAT_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_MOTOR_mask_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2read_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2repeat_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2motor_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2read_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2repeat_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2motor_seldet.resp_orig.nii.gz
# 
# registerTo1mmMNI152.sh \
# -s JPAS01-1 \
# -t /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2.3Danat_orig.nii.gz \
# -o /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Register_3-15-11 \
# -l /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1_Lesionmask.nii.gz \
# -e /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.epi01.trega_orig_chopped.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_READ_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_REPEAT_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_MOTOR_mask_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2read_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2repeat_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2motor_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2read_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2repeat_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2motor_seldet.resp_orig.nii.gz
# 
# registerTo1mmMNI152.sh \
# -s JPAS03-2 \
# -t /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.CDA2.3Danat_orig.nii.gz \
# -o /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/Register_3-17-11 \
# -l /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2_Lesionmask.nii.gz \
# -e /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.epi01.trega_orig_chopped.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/Clust_JPAS03-2_3-2_READ_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/Clust_JPAS03-2_3-2_REPEAT_mask_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.CDA2read_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.CDA2repeat_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.CDA2read_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS03-2/afnifiles/JPAS03-2.CDA2repeat_seldet.resp_orig.nii.gz

##############################################################################################3
#starting with the first of three: 

#original command:
registerTo1mmMNI152.sh \
-s PAS07-1 \
-t /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2.3Danat_orig.nii.gz \
-o /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Register_bet \
-l /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1_Lesionmask.nii.gz \
-e /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.epi01_bet.nii.gz \
-c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_READ_mask_orig.nii.gz \
#-c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_REPEAT_mask_orig.nii.gz \
#-c /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/Clust_PAS07-1_3-2_MOTOR_mask_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2read_seldet.buck_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2repeat_seldet.buck_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2motor_seldet.buck_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2read_seldet.resp_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2repeat_seldet.resp_orig.nii.gz \
#-b /data/birc/RESEARCH/CONWAY_CDA2/s07CDA1/afnifiles/PAS07-1.CDA2motor_seldet.resp_orig.nii.gz

# Per stowler visual inspection: t1 and lesion seem well-alligend
# Per stowler visual inspection: brain seems well-extracted, with lesion excluded from brain
# Per stowler visual inspection: t1 and lesion registration to 1mmMNI152 template are *excellent*
# Per stowler visual inspection: EPI is completely mis-warped to 1mmMNI152 template

# ...and after switching from full epi to epi_averaged: no better....
# ...and after adding "-fineserach" to flirt:
# ...and after         


# second participant
registerTo1mmMNI152.sh \
-s JPAS01-1 \
-t /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2.3Danat_orig.nii.gz \
-o /tmp/danaTest2 \
-l /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1_Lesionmask.nii.gz \
-e /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.epi01.trega_orig_chopped.nii.gz \
-c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_READ_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_REPEAT_mask_orig.nii.gz \
# -c /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/Clust_JPAS01-1_3-2_MOTOR_mask_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2read_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2repeat_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2motor_seldet.buck_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2read_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2repeat_seldet.resp_orig.nii.gz \
# -b /data/birc/RESEARCH/CONWAY_CDA2/JPAS01-1/afnifiles/JPAS01-1.CDA2motor_seldet.resp_orig.nii.gz
  

