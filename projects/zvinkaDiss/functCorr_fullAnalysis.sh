#/bin/sh

source $bwDir/projects/zvinkaDiss/zz-environment.sh



# assemble individual participant rsq values into a single .csv with header

rm -f ${outDir}/pearsonr_roi1_roi2_eachSubject.csv
echo "subj,pearsonr_roi1_roi2" >  ${outDir}/pearsonr_roi1_roi2_eachSubject.csv
for subj in `echo $subjsYoung $subjsSedent $subjsActive`; do
	ls -al ${outDir}/${subj}.results/corrPearson_PFC_RSP_cleaned.csv
	cat ${outDir}/${subj}.results/corrPearson_PFC_RSP_cleaned.csv | tee -a  ${outDir}/pearsonr_roi1_roi2_eachSubject.csv
done

echo ""
ls -al  ${outDir}/pearsonr_roi1_roi2_eachSubject.csv
wc  ${outDir}/pearsonr_roi1_roi2_eachSubject.csv
cat ${outDir}/pearsonr_roi1_roi2_eachSubject.csv

# upload to google docs:
java -jar /data/birc/RESEARCH/brainwhere//utilitiesAndData/google-docs-upload-1.4.6.jar ${outDir}/pearsonr_roi1_roi2_eachSubject.csv


# then log on to googledos and make sure it's sharable as csv (for R download)
