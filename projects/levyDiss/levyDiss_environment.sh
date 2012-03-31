#!/bin/sh
# setup environment for subsequent scripts:
export studyDir="/data/birc/RESEARCH/STN/SUBCORT_DISS_2009/SC"
export outDir="${studyDir}/stowler_reprocess"
export subjsYoung="002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017"
export subjsYoung_column="`echo ${subjsYoung} | sed 's/ /\n/g'`"
export subjsOld="101 102 103 104 107 108 109 110 112 113 114 116 117 118 119"
export subjsOld_column="`echo ${subjsOld} | sed 's/ /\n/g'`"
export subjs="`echo ${subjsYoung}` `echo ${subjsOld}`"
export subjs_column="`echo ${subjs} | sed 's/ /\n/g'`"

echo ""
echo "studyDir=${studyDir}"
echo "outDir=${outDir}"
echo "subjsYoung=${subjsYoung}"
echo "subjsOld=${subjsOld}"
echo "subjs=${subjs}"
echo ""
