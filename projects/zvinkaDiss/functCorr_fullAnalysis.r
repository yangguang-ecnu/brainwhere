#!/usr/bin/Rscript
# This script contains r commands for  processing functional correlation data
# 


library(psychometric)

# get csv of master database
# broken at the moment:
#	zzMaster<-(read.csv("https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdDlQUzVHSzJwdHVMRHU3QURUd0JPN0E&single=true&gid=0&output=csv&ndplr=1"))


zzMaster.url<-"https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdDlQUzVHSzJwdHVMRHU3QURUd0JPN0E&single=true&gid=0&output=csv&ndplr=1"
#zzCorrs.url<-"https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdDJ0NDdFNS1fSFNpWHMyaC12VTdMN2c&single=true&gid=0&output=csv&ndplr=1"
#zzCorrs.url<-"https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdDJ0NDdFNS1fSFNpWHMyaC12VTdMN2c&single=true&gid=0&output=csv&ndplr=1"
download.file(zzMaster.url, "/tmp/zzMaster.csv", method = "wget") # may need to use curl if that's what's installed
download.file(zzCorrs.url, "/tmp/zzCorrelations.csv", method = "wget")
zzMaster<-(read.csv("/tmp/zzMaster.csv"))
zzCorrs<-(read.csv("/tmp/zzCorrelations.csv"))

# str(zzMaster)
# ...reveals that's a lot of variables. Drop all variables except for "Subject.." and "Age":
zzDemographics <- subset(zzMaster, select=c(Subject..,Age))

# str(zzDemographics)
# ...reveals wow 277 factors for "Subject..". That can't be right...
# levels(zzDemographics$Subject..)
# ...reveals yup, lots of artifactual levels. Let's  see which obs are reaL:
# zzDemographics
# ...looks like only rows 2-50 are real. Let's cut the rest out:
zzDemographics <- zzDemographics[2:50, ]

# zzDemographics
# levels(zzDemographics$Subject..)
# ...reveal that now we have the right obs, but artifactual factors persist. 
# Let's prune those unused factors and fix variable names at same time:
zzDemographics <- data.frame(subj=zzDemographics$Subject.. [,drop=TRUE], age=zzDemographics$Age)

# zzDemographics
# levels(zzDemographics$subj)
# ....revleals four weird subj levels, probably from excel comments:
#	s05 [218]
#	s106 [219]
#	s111 [220]
#	s205 [222]
# Let's fix those by renaming factor levels:
levels(zzDemographics$subj)[levels(zzDemographics$subj)=="s05 [218]"]<-"s05"
levels(zzDemographics$subj)[levels(zzDemographics$subj)=="s106 [219]"]<-"s106"
levels(zzDemographics$subj)[levels(zzDemographics$subj)=="s111 [220]"]<-"s111"
levels(zzDemographics$subj)[levels(zzDemographics$subj)=="s205 [222]"]<-"s205"

# and now code group based on ZZ's participant naming conventions:
# young: 	grepl("s..$", zzDemographics$subj)
# oldSedent: 	grepl("s1..$", zzDemographics$subj)
# oldActive: 	grepl("s2..$", zzDemographics$subj)
attach(zzDemographics)
zzDemographics$group[grepl("s..$", zzDemographics$subj)]<-"young" 
zzDemographics$group[grepl("s1..$", zzDemographics$subj)]<-"oldSedent"
zzDemographics$group[grepl("s2..$", zzDemographics$subj)]<-"oldActive"
detach(zzDemographics)

# convert new group variable from chr to a factor:
zzDemographics$group<-factor(zzDemographics$group)

# merge the demographics and imaging data:
zzFunctCorr<-merge(zzDemographics, zzCorrs, ID="subj")

# transform r into z(r)
zzFunctCorr$zr<-r2z(zzFunctCorr$pearsonr_roi1_roi2)

# plot
with(zzFunctCorr,
    ggplot() +
    geom_point(aes(x = age,y = zr ,colour = group),data=zzFunctCorr, alpha=0.6) +
    geom_smooth(aes(x = age ,y = zr ,colour = group),data=zzFunctCorr,method = 'lm',formula = 'y ~ x', se = FALSE) +
    xlab("Age (years)") +
    ylab("Correlation z(r)") +
    opts(
        title=paste("Anterior to Poster Functional Correlations \nMay Differ Among Zvinka's Groups"),
        plot.title = theme_text(size=25),
        axis.title.y = theme_text(size=20, angle=90),
        axis.title.x = theme_text(size=20)
    )
)

# calculate per-group Pearson correlations:
by(zzFunctCorr, list(zzFunctCorr$group), function(tempDF) with(tempDF,
     cor.test(
          zr,
          age,
     )
)) # double close parens are not an error

# calculate per-group Spearman rho correlations:
by(zzFunctCorr, list(zzFunctCorr$group), function(tempDF) with(tempDF,
     cor.test(
          zr,
          age,
          method="spearman",
     )
)) # double close parens are not an error


ggplot() +
	geom_boxplot(aes(y = zr,x = group),data=zzFunctCorr,position = position_dodge(width = 0.9))  +
	xlab("group") +
	ylab("z(r)") +
    	opts(
		title=paste("Anterior to Poster Functional Correlations \nMay Differ Among Zvinka's Groups"),
		plot.title = theme_text(size=25),
		axis.title.y = theme_text(size=20, angle=90),
		axis.title.x = theme_text(size=20)
	)

