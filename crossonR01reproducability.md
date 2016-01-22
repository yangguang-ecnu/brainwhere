# How to visualize and reproduce crossonR01 laterality results (MB deconvolutions -> gamma filtering -> final plots) #

As of May 12, 2011, recent results for the [R01](https://code.google.com/p/brainwhere/source/detail?r=01) intention project include these deliverables in support of the SFN abstract:
  * [This PDF](https://docs.google.com/viewer?a=v&pid=explorer&chrome=true&srcid=0B9QwiwfBQVsYZDUwODE0ZjAtZmJkYS00OTJmLWE0OTQtZGNmZjc4MTRiZGM3&hl=en&authkey=CNumkZwM) containing barplots for laterality index and laterality index change, plus scatterplots for cstat.Z vs. change in laterality index.
  * [This summary spreadsheet](https://spreadsheets.google.com/ccc?key=0AtQwiwfBQVsYdDc3cWt2eVpNblBlTTU5eTVtV1Ytcmc&hl=en&authkey=CIKkhlU) containing one-group two-sided t-tests for H0: 0 = change in laterality index, and, on the second worksheet, Pearson's r and Spearman's rho for cstat.Z vs. change in laterality index.
  * [This text file](https://docs.google.com/document/d/1x3HlYPdOI7pu86vcZTtM7CdMvqkVgduzNnE4ordW2lM/edit?hl=en&authkey=CK6w08EK) of raw output statistics for the t-tests and correlations summarized above.
  * ...all of which is generated from [this spreadsheet](https://spreadsheets.google.com/ccc?key=0AtQwiwfBQVsYdEdJWC1fNkJUaGRjb1pHOV9qWmpWdFE&hl=en&authkey=CNPyuroJ) of cstat.Z values extracted from MB's spreadsheets...
  * ...and from [this spreadsheet](https://spreadsheets.google.com/ccc?key=0AtQwiwfBQVsYdFZOTnNHMGM1c09WRWc4aXUzYVRTWHc&hl=en&authkey=CJvD5qoE) of left and right superthreshold volumes from which laterality index and change in laterality index were calculated.


Please feel free to double-check any of the work and I welcome any suggestions about the plots. The data above were subject to these analysis policies:
  * exclude participants with PRE lateral frontal LI < -0.8 (i.e., more right lateralized than -0.8, which was limited to INT2\_s13)
  * 0 bilateral vol for an ROI is assigned LI == 0 by convention
  * lacking 3mo scan does not exclude participant from pre and post analysis
  * unstable baseline c-stat is not an exclusion criterion for imaging data, but…..
  * POST c-stat should be dropped from analyses if baseline c-stat was unstable AND positive (which IS the case for INT2\_s06 naming baseline and INT2\_s19 category baseline)
  * analyses of naming c-stats and category c-stats are independent (i.e., excluding a participant's NAMING c-stat from analysis does not require excluding that participant's CATEGORY c-stat and vice versa


In this video: (TBD)

I narrate a walk-through of the steps necessary to start with MBs original deconvolutions and create gamma-variate-filtered data including all of the data listed at the top of this page.

Mechanically the entire processing stream, including manual inspections at the end, is accomplished for all participants and sessions in four steps, reproduced with these short commands:

```
#################################################################################################
# STEP 1 of 4: process MB's original non-seldet deconvolutions into
# gamma-filtered cluster masks and resulting cluster reports.  The output to be
# passed from this to STEP 2 is one cluster report text file per session stored as:
# ${parentDir}/${blind}/${session}/afnifiles/${blind}_${session}_clust.12thresh.50ul_reportBW_1mmCrosson3roiVer2Only.txt

# switch to bash shell and get intentionBlinds and controlBlinds:
bash
source ${bwDir}/projects/crossonR01/r01-environment.sh

# ...then this double loop executes the full processing script for each participant and session (1-2 hours per session):
# (normally I split this across parallel GNU screen sessions, but here I show in serial for simplicity)
for blind in `echo ${intentionBlinds} ${controlBlinds}`; do
     for session in pre post 3mo; do
          ${bwDir}/projects/crossonR01/r01-gam.sh -s -g -p -c -b ${blind} -t ${session}
     done
done
```

...the ${bwDir}/projects/crossonR01/[r01-gam.sh](https://code.google.com/p/brainwhere/source/browse/projects/crossonR01/r01-gam.sh) brainwhere script referenced above calls a number of other brainwhere scripts, including:
  * ${bwDir}/project/[r01-environment.sh](https://code.google.com/p/brainwhere/source/browse/projects/crossonR01/r01-environment.sh)
  * ${bwDir}/utilitiesAndData/[brainwhereCommonFunctions.sh](https://code.google.com/p/brainwhere/source/browse/utilitiesAndData/brainwhereCommonFunctions.sh)
  * ${bwDir}/[displayImageGeometry.sh](https://code.google.com/p/brainwhere/source/browse/displayImageGeometry.sh)
  * ${bwDir}/[registerTo1mmMNI152.sh](https://code.google.com/p/brainwhere/source/browse/registerTo1mmMNI152.sh)
  * ${bwDir}/[clusterReporter.sh](https://code.google.com/p/brainwhere/source/browse/clusterReporter.sh)
You may inspect the current source code of any of these scripts by clicking on their names above.

```
#################################################################################################
# STEP 2 of 4: from the resulting cluster reports, extract the final
# supra-threshold volume of clusters intersecting each a priori ROI.  This step
# produces a long-format CSV file for plotting, in which each line is:
# ${blind} ${group} ${session} ${roi} ${ulLeft} ${ulRight}

rm -f /tmp/r01_li_long.csv
sh ${bwDir}/projects/crossonR01/r01-extractLongVolumes.sh | tee -a /tmp/r01_li_long.csv

# ...and then optionally upload to google docs for easy email to collaborators:
# java -jar $bwDir/utilitiesAndData/google-docs-upload-1.4.6.jar /tmp/r01_li_long.csv
```

...and you may inspect the current version of ${bwDir}/projects/crossonR01/[r01-extractLongVolumes.sh](https://code.google.com/p/brainwhere/source/browse/projects/crossonR01/r01-extractLongVolumes.sh) by clicking on it.

```
#################################################################################################
# STEP 3 of 4: create PDF with plots of laterality index and change in laterality index

rm -f /tmp/r01-plots.pdf
R CMD BATCH ${bwDir}/projects/crossonR01/r01-plot.r
acroread /tmp/r01-plots.pdf

# ...and then optionally upload to google docs for easy email to collaborators:
# java -jar $bwDir/utilitiesAndData/google-docs-upload-1.4.6.jar /tmp/r01_plots.pdf
```

...and you may inspect the current version of ${bwDir}/projects/crossonR01/[r01-plot.r](https://code.google.com/p/brainwhere/source/browse/projects/crossonR01/r01-plot.r) by clicking on it.

```
#################################################################################################
# STEP 4 OF 4: VERIFY RESULTS


# Visually verify that EPI-to-T1 rigid-body registrations were reasonable.
# script opens fslview with a number of layers.
# Just substitute for ${blind} and ${session} below, e.g.,
# sh ${bwDir}/projects/crossonR01/r01-verify-reg-func2struct.sh INT2_s04 pre
  sh ${bwDir}/projects/crososnR01/r01-verify-reg-func2struct.sh ${blind} ${session}

# Visually verify that EPI-to-MNI152 nonlinear registrations were reasonable.
# Script opens fslview with a number of layers.
# Just substitute for ${blind} and ${session} below, e.g.,
# sh ${bwDir}/projects/crossonR01/r01-verify-reg-mni152-nonlinear.sh INT2_s04 pre
  sh ${bwDir}/projects/crososnR01/r01-verify-reg-mni152-nonlinear.sh ${blind} ${session}

# Visually verify that volumes in the cluster reports match actual overlap of suprathreshold
# clusters and apriori ROIs? Script opens fslview with layers and gedit with cluster report.
# Just substitute for ${blind} and ${session} below, e.g.,
# sh ${bwDir}/projects/crossonR01/r01-verify-reportedOverlap.sh INT2_s04 pre
  sh ${bwDir}/projects/crossonR01/r01-verify-reportedOverlap.sh ${blind} ${session}


# Manually verify that laterality plots accurately reflect lines in cluster reports:
sh ${bwDir}/projects/crossonR01/r01-verify-plots-laterality.sh


```
...and just like the others, the current versions of these brainwhere scripts are [browsable](https://code.google.com/p/brainwhere/source/browse/projects).