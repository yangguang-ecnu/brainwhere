#!/usr/bin/Rscript
# This script contains r commands for creating plots of crossonR01 data:
# 
# Notes about analysis and visualization choices:
# - mean and sd calculated without NAs (i.e., if division by zero results in LI
#   or LIchange of NA, those sessions aren't counted in n used to calculate mean
#   and sd)
# - though range of LI is 1 to -1, showing 2 to -2 on axis to make equivalent
#   with range of LIchange


#########################################################################################
# LOAD LIBRARIES AND IMPORT DATA:
#
# load required libraries:
library(ggplot2)
library(plyr)
library(reshape2)

# import supra-threshold fmri volumes from csv and double-check it:
# !!!!! broken right now: data.long<-(read.csv("https://docs.google.com/spreadsheet/pub?key=0AtQwiwfBQVsYdEJ1aEhvdGNIMHRxOVhuWHBQTVppWWc&single=true&gid=0&range=A1%3AC20&output=csv&ndplr=1"))
data.long.url<-"https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdFZOTnNHMGM1c09WRWc4aXUzYVRTWHc&single=true&gid=0&output=csv&ndplr=1"
download.file(data.long.url, "/tmp/r01_li_long.csv", method = "wget")
data.long<-(read.csv("/tmp/r01_li_long.csv"))
head(data.long)
str(data.long)
summary(data.long)

# import cstats from csv and double-check it:
data.cstat.url<-"https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0AtQwiwfBQVsYdEdJWC1fNkJUaGRjb1pHOV9qWmpWdFE&single=true&gid=0&output=csv&ndplr=1"
download.file(data.cstat.url, "/tmp/r01_cstat_z.csv", method = "wget")
data.cstat<-(read.csv("/tmp/r01_cstat_z.csv"))
head(data.cstat)
str(data.cstat)
summary(data.cstat)

# calculate LI and spot-check:
# (Results in NaN when dividing by zero, which we set to zero by convention)
data.long <- transform(data.long, LI=(ulLeft-ulRight)/(ulLeft+ulRight))
head(data.long)
summary(data.long)
# ^^ notice NA's in LI summary. Change to zeros by convention:
data.long[sapply(data.long,is.na)] = 0
summary(data.long)


#########################################################################################
# RENAME AND REORDER FACTOR LEVELS FOR BETTER PLOTING:
#
# change factor level "3mo" to "followup" for better naming
levels(data.long$session)[levels(data.long$session)=="3mo"]<-"followup"
levels(data.long$session)
# order session levels:
data.long$session <- factor(data.long$session, levels=c("pre","post","followup"))
levels(data.long$session)
# reorder participants to reflect treatment then controls (new for poster):
data.long$participant <- factor(data.long$participant, levels=c("INT2_s01","INT2_s03","INT2_s05","INT2_s06","INT2_s11","INT2_s12","INT2_s15","INT2_s04","INT2_s07","INT2_s08","INT2_s10","INT2_s14","INT2_s16","INT2_s19"))
levels(data.long$participant)
# improve ordering for display in faceted coord_flip'd axes:
data.long$participant<-factor(data.long$participant,levels=rev(levels(data.long$participant)))
data.long$group<-factor(data.long$group, levels=rev(levels(data.long$group)))
data.long$roi<-factor(data.long$roi, levels=c("CROSSONlateralFrontalROI","CROSSONPerisylvian","CROSSONmedialFrontal"))
# more factor ordering help:
# reorder()
# refactor()

# get rid of "INT2_" at front of participant IDs...
#...in data.long:
levels(data.long$participant)[levels(data.long$participant)=="INT2_s01"]<-"s01"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s03"]<-"s03"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s05"]<-"s05"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s06"]<-"s06"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s11"]<-"s11"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s12"]<-"s12"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s15"]<-"s15"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s04"]<-"s04"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s07"]<-"s07"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s08"]<-"s08"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s10"]<-"s10"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s14"]<-"s14"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s16"]<-"s16"
levels(data.long$participant)[levels(data.long$participant)=="INT2_s19"]<-"s19"
#...and in data.cstat:
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s01"]<-"s01"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s03"]<-"s03"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s05"]<-"s05"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s06"]<-"s06"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s11"]<-"s11"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s12"]<-"s12"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s15"]<-"s15"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s04"]<-"s04"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s07"]<-"s07"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s08"]<-"s08"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s10"]<-"s10"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s14"]<-"s14"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s16"]<-"s16"
levels(data.cstat$participant)[levels(data.cstat$participant)=="INT2_s19"]<-"s19"


#########################################################################################
# CALCULATE SUMMARY STATS
#
# Calculate separate means and standard deviations for each ROI:
data.long.lateralFrontal<-subset(data.long,roi == "CROSSONlateralFrontalROI")
data.long.perisylvian<-subset(data.long,roi == "CROSSONPerisylvian")
data.long.medialFrontal<-subset(data.long,roi == "CROSSONmedialFrontal")
LI.mean.all<-mean(data.long$LI, na.rm=TRUE)
LI.mean.lateralFrontal<-mean(data.long.lateralFrontal$LI, na.rm=TRUE)
#LI.mean.lateralFrontal.control<-
#LI.mean.lateralFrontal.intention<-
LI.mean.perisylvian<-mean(data.long.perisylvian$LI, na.rm=TRUE)
#LI.mean.perisylvian.control<-
#LI.mean.perisylvian.intention<-
LI.mean.medialFrontal<-mean(data.long.medialFrontal$LI, na.rm=TRUE)
#LI.mean.medialFrontal.control<-
#LI.mean.medialFrontal.intention<-
#
#....and here's the same thing but for SD:
LI.sd.all<-sd(data.long$LI, na.rm=TRUE)
LI.sd.lateralFrontal<-sd(data.long.lateralFrontal$LI, na.rm=TRUE)
#LI.sd.lateralFrontal.control<-
#LI.sd.lateralFrontal.intention<-
LI.sd.perisylvian<-sd(data.long.perisylvian$LI, na.rm=TRUE)
#LI.sd.perisylvian.control<-
#LI.sd.perisylvian.intention<-
LI.sd.medialFrontal<-sd(data.long.medialFrontal$LI, na.rm=TRUE)
#LI.sd.medialFrontal.control<-
#LI.sd.medialFrontal.intention<-

# TBD: calculate max for LI axis by greater than max LI or mean+-SD


###########################################################################################
# RESTRUCTURE DATA AND PREP FOR PLOTS
#

#  pivot and restructure data to wide format for calculation of LIchange1 and LIchange2:
data.wide <- dcast(data.long, participant + group + roi ~ session, value_var="LI")
str(data.wide)
summary(data.wide)
# calculate LIchange1 and LIchange2:
data.wide <- transform(data.wide, LIchange1.post=(post-pre))
data.wide <- transform(data.wide, LIchange2.followup=(followup-pre))
# melt data for plotting and fix resulting variable names:
data.long.change<-melt(data.wide, id.vars=c("participant","group","roi"), measure.vars=c("LIchange1.post","LIchange2.followup"), variable.name=c("LIchange.signed"))
head(data.long.change)
names(data.long.change)[names(data.long.change)=="variable"]<-"LIchange.period"
names(data.long.change)[names(data.long.change)=="value"]<-"LIchange.signed"
summary(data.long.change)
# add cstat data:
data.long.change<-(join(data.long.change, data.cstat, by="participant"))
# subset for plotting just post:
data.long.change.post<-subset(data.long.change, LIchange.period == "LIchange1.post")



#############################################################################################
# GENERATE PLOTS
# (For color options, display brewer pallettes: RColorBrewer::display.brewer.all)

#...start by sprucing up facet labels (modeled from http://wiki.stdout.org/rcookbook/Graphs/Facets%20(ggplot2) ) :
labeller.poster <- function(var, value){
	value <- as.character(value)
	if (var=="roi") {
		value[value=="CROSSONlateralFrontalROI"] 	<- "Lateral frontal"
		value[value=="CROSSONPerisylvian"] 			<- "Posterior perisylvian"
		value[value=="CROSSONmedialFrontal"] 		<- "Medial frontal"
	}
	if (var=="LIchange.period") {
		value[value=="LIchange1.post"] 				<- "(post) - (pre)"
		value[value=="LIchange2.followup"] 			<- "(3-mo. follow-up) - (pre)"
	}
	if (var=="participant") {
		value[value=="INT2_s01"] 				<- "s01"
		value[value=="INT2_s03"] 				<- "s03"
		value[value=="INT2_s05"] 				<- "s05"
		value[value=="INT2_s06"] 				<- "s06"
		value[value=="INT2_s11"] 				<- "s11"
		value[value=="INT2_s12"] 				<- "s12"
		value[value=="INT2_s15"] 				<- "s15"
		value[value=="INT2_s04"] 				<- "s04"
		value[value=="INT2_s07"] 				<- "s07"
		value[value=="INT2_s08"] 				<- "s08"
		value[value=="INT2_s10"] 				<- "s10"
		value[value=="INT2_s14"] 				<- "s14"
		value[value=="INT2_s16"] 				<- "s16"
		value[value=="INT2_s19"] 				<- "s19"
	}
	return(value)
}

# Create LI bar plot with x and y axes flipped. Notice negative dodging to get pre/post/3mo order correct:
# ....+ scale_y_reverse also works to put negatives LIs on right, but ylim also allows control of range:
# (TBD: also eventually try as a dotchart with geom_point + geom_segment)
p.laterality<-ggplot(data.long, aes(participant, LI, fill=session)) +
	# ...add the elements that should appear in the background (line for mean and shading for SD):
	# (weirdly (b/c of axis flip?), min and max have to be given as -1*VARIABLE here:)
	geom_hline(yintercept=LI.mean.all, linetype="dashed") + 
	geom_rect(ymin=-LI.mean.all+LI.sd.all, ymax=-LI.mean.all-LI.sd.all, xmin=0, xmax=Inf, fill="purple", alpha=0.02) +
	geom_hline(yintercept=0) +
	# ...and now add the foreground barplot and everything else:
	geom_bar(stat="identity", position=position_dodge(width=-.75)) + 
	coord_flip() + 
	facet_grid(roi ~ group, space="free", labeller=labeller.poster) + 
	ylim(2,-2) + 
	scale_fill_brewer(palette="YlOrRd") + 
	theme_bw() + ylab("Laterality Index") + 
	opts(
		title=paste("Pre, Post, and Follow-Up Laterality Indicies for \nThree Anatomical Regions\n(grand mean LI=", round(LI.mean.all, digits=2), ", sd=" ,round(LI.sd.all, digits=2),")" )
	)
# ...display:
#p.laterality


# new plot for SFN poster:
p.lateralityChange<-ggplot(data.long.change, aes(participant, LIchange.signed, fill=group)) +
	geom_bar(stat="identity") + 
	coord_flip() + 
	facet_grid(roi ~ LIchange.period, space="free", labeller=labeller.poster) + 
	ylim(2,-2) + 
	xlab("Participants") +
	ylab("Change in laterality index") + 
	opts(title=paste("Change in category laterality index") +
	opts(
		plot.title = theme_text(size=25, vjust=1.4 ), 
		strip.text.x = theme_text(size=14), 
		strip.text.y = theme_text(size=14, angle=-90), 
		axis.title.x = theme_text(size=20, vjust=.2),
		axis.title.y = theme_text(size=20, angle=90, vjust=.3),
		panel.margin = unit(.25, "cm")
	)
# ...display:
#p.lateralityChange

# old, pre-poster lateralityChange plot for all regions:
# p.lateralityChange<-ggplot(data.long.change, aes(participant, LIchange.signed, fill=LIchange.period)) +
# 	# ...add the elements that should appear in the background (line for mean and shading for SD):
# 	# (weirdly (b/c of axis flip?), min and max have to be given as -1*VARIABLE here:)
# 	geom_hline(yintercept=LIchange.mean.all, linetype="dashed") + 
# 	geom_rect(ymin=-LIchange.mean.all+LIchange.sd.all, ymax=-LIchange.mean.all-LIchange.sd.all, xmin=0, xmax=Inf, fill="purple", alpha=0.02) +
# 	geom_hline(yintercept=0) +
# 	# ...and now add the foreground barplot and everything else:
# 	geom_bar(stat="identity", position=position_dodge(width=-.75)) + 
# 	coord_flip() + 
# 	facet_grid(roi ~ group, space="free") + 
# 	ylim(2,-2) + 
# 	scale_fill_brewer(palette="Blues") + 
# 	theme_bw() + ylab("Signed Change in Laterality Index") + 
# 	opts(title=paste("Change in Laterality Index for Three Anatomical Regions:\nPre-to-Post and Pre-to-Follow-Up \n(grand mean LIchange=", round(LIchange.mean.all, digits=2), ", sd=" ,round(LIchange.sd.all, digits=2),")" ))
# # ...display:
# p.lateralityChange


# plot correlation between LI change and categories cstat
p.corr.categories <- ggplot(data.long.change.post,aes(LIchange.signed, category.cstat.Z.post)) + 
	geom_point(shape=1,size=2) + 
	geom_smooth(method=lm) + 
	scale_x_reverse() + 
	facet_grid(roi ~ group, labeller=labeller.poster) +
	ylab("Category c-statistic") +
	xlab("Change in laterality index") +
	opts(
		title=paste("Correlation between treatment change\n and laterality index change"),
		plot.title = theme_text(size=25, vjust=1.4 ), 
		strip.text.x = theme_text(size=13), 
		strip.text.y = theme_text(size=13, angle=-90), 
		axis.title.x = theme_text(size=20, vjust=.2),
		axis.title.y = theme_text(size=20, angle=90, vjust=.3),
		panel.margin = unit(.25, "cm")
	)
	
	
# plot correlation between LI change and naming cstat:
p.corr.naming     <- ggplot(data.long.change.post,aes(LIchange.signed, naming.cstat.Z.post)) + 
	geom_point(shape=1,size=2) + 
	geom_smooth(method=lm) + 
	scale_x_reverse() +
	facet_grid(roi ~ group, labeller=labeller.poster) +
	ylab("Naming c-statistic") +
	xlab("Change in laterality index") +
	opts(
		title=paste("Correlation between treatment change\n and laterality index change"),
		plot.title = theme_text(size=25, vjust=1.4 ), 
		strip.text.x = theme_text(size=13), 
		strip.text.y = theme_text(size=13, angle=-90), 
		axis.title.x = theme_text(size=20, vjust=.2),
		axis.title.y = theme_text(size=20, angle=90, vjust=.3),
		panel.margin = unit(.25, "cm")
	)




# subset for plots and stats by region per BC:
data.long.change.lateralFrontal<-subset(data.long.change,roi == "CROSSONlateralFrontalROI")
	data.long.change.lateralFrontal.LIchange1.post<-subset(data.long.change.lateralFrontal, LIchange.period == "LIchange1.post")
		data.long.change.lateralFrontal.LIchange1.post.intention<-subset(data.long.change.lateralFrontal.LIchange1.post, group == "intention")
		data.long.change.lateralFrontal.LIchange1.post.control  <-subset(data.long.change.lateralFrontal.LIchange1.post, group == "control")
	data.long.change.lateralFrontal.LIchange2.followup<-subset(data.long.change.lateralFrontal, LIchange.period == "LIchange2.followup")
		data.long.change.lateralFrontal.LIchange2.followup.intention<-subset(data.long.change.lateralFrontal.LIchange2.followup, group == "intention")
		data.long.change.lateralFrontal.LIchange2.followup.control  <-subset(data.long.change.lateralFrontal.LIchange2.followup, group == "control")

data.long.change.perisylvian<-subset(data.long.change,roi == "CROSSONPerisylvian")
	data.long.change.perisylvian.LIchange1.post<-subset(data.long.change.perisylvian, LIchange.period == "LIchange1.post")
		data.long.change.perisylvian.LIchange1.post.intention<-subset(data.long.change.perisylvian.LIchange1.post, group == "intention")
		data.long.change.perisylvian.LIchange1.post.control  <-subset(data.long.change.perisylvian.LIchange1.post, group == "control")
	data.long.change.perisylvian.LIchange2.followup<-subset(data.long.change.perisylvian, LIchange.period == "LIchange2.followup")
		data.long.change.perisylvian.LIchange2.followup.intention<-subset(data.long.change.perisylvian.LIchange2.followup, group == "intention")
		data.long.change.perisylvian.LIchange2.followup.control  <-subset(data.long.change.perisylvian.LIchange2.followup, group == "control")

data.long.change.medialFrontal<-subset(data.long.change,roi == "CROSSONmedialFrontal")
	data.long.change.medialFrontal.LIchange1.post<-subset(data.long.change.medialFrontal, LIchange.period == "LIchange1.post")
		data.long.change.medialFrontal.LIchange1.post.intention<-subset(data.long.change.medialFrontal.LIchange1.post, group == "intention")
		data.long.change.medialFrontal.LIchange1.post.control  <-subset(data.long.change.medialFrontal.LIchange1.post, group == "control")
	data.long.change.medialFrontal.LIchange2.followup<-subset(data.long.change.medialFrontal, LIchange.period == "LIchange2.followup")
		data.long.change.medialFrontal.LIchange2.followup.intention<-subset(data.long.change.medialFrontal.LIchange2.followup, group == "intention")
		data.long.change.medialFrontal.LIchange2.followup.control  <-subset(data.long.change.medialFrontal.LIchange2.followup, group == "control")

#########################################################################################################################
# calcualte means, standard deviations, and t-test:

LIchange.mean.all<-mean(data.long.change$LIchange.signed, na.rm=TRUE)
LIchange.mean.lateralFrontal<-mean(data.long.change.lateralFrontal$LIchange.signed, na.rm=TRUE)
#LIchange.mean.lateralFrontal.control<-
#LIchange.mean.lateralFrontal.intention<-
LIchange.mean.perisylvian<-mean(data.long.change.perisylvian$LIchange.signed, na.rm=TRUE)
#LIchange.mean.perisylvian.control<-
#LIchange.mean.perisylvian.intention<-
LIchange.mean.medialFrontal<-mean(data.long.change.medialFrontal$LIchange.signed, na.rm=TRUE)
#LIchange.mean.medialFrontal.control<-
#LIchange.mean.medialFrontal.intention<-

LIchange.sd.all<-sd(data.long.change$LIchange.signed, na.rm=TRUE)
LIchange.sd.lateralFrontal<-sd(data.long.change.lateralFrontal$LIchange.signed, na.rm=TRUE)
#LIchange.sd.lateralFrontal.control<-
#LIchange.sd.lateralFrontal.intention<-
LIchange.sd.perisylvian<-sd(data.long.change.perisylvian$LIchange.signed, na.rm=TRUE)
#LIchange.sd.perisylvian.control<-
#LIchange.sd.perisylvian.intention<-
LIchange.sd.medialFrontal<-sd(data.long.change.medialFrontal$LIchange.signed, na.rm=TRUE)
#LIchange.sd.medialFrontal.control<-
#LIchange.sd.medialFrontal.intention<-

######################################################################################
# CORRELATIONS AND One-group two-tailed t-tests... 
#

# ...for lateralFrontal
c("H0: 0 = mean of LIchange for lateralFrontal pre-to-post intention participants :")
t.test(data.long.change.lateralFrontal.LIchange1.post.intention$LIchange.signed, mu=0, alternative="two.sided")
#with(data.long.change.lateralFrontal.LIchange1.post.intention, cor(LIchange.signed,category.cstat.Z.post,use="pairwise.complete.obs"))
#with(data.long.change.lateralFrontal.LIchange1.post.intention, cor(LIchange.signed,naming.cstat.Z.post,use="pairwise.complete.obs"))
cor.test(data.long.change.lateralFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.lateralFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")


c("H0: 0 = mean of LIchange for lateralFrontal pre-to-post control participants :")
t.test(data.long.change.lateralFrontal.LIchange1.post.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.lateralFrontal.LIchange1.post.control$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange1.post.control$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.lateralFrontal.LIchange1.post.control$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange1.post.control$LIchange.signed, data.long.change.lateralFrontal.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="spearman")


c("H0: 0 = mean of LIchange for lateralFrontal pre-to-followup intention participants :")
t.test(data.long.change.lateralFrontal.LIchange2.followup.intention$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")


c("H0: 0 = mean of LIchange for lateralFrontal pre-to-followup control participants :")
t.test(data.long.change.lateralFrontal.LIchange2.followup.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.lateralFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.lateralFrontal.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="spearman")

# ...for perisylvian
c("H0: 0 = mean of LIchange for perisylvian pre-to-post intention participants :")
t.test(data.long.change.perisylvian.LIchange1.post.intention$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.perisylvian.LIchange1.post.intention$LIchange.signed, data.long.change.perisylvian.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange1.post.intention$LIchange.signed, data.long.change.perisylvian.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.perisylvian.LIchange1.post.intention$LIchange.signed, data.long.change.perisylvian.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange1.post.intention$LIchange.signed, data.long.change.perisylvian.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")


c("H0: 0 = mean of LIchange for perisylvian pre-to-post control participants :")
t.test(data.long.change.perisylvian.LIchange1.post.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.perisylvian.LIchange1.post.control$LIchange.signed, data.long.change.perisylvian.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange1.post.control$LIchange.signed, data.long.change.perisylvian.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.perisylvian.LIchange1.post.control$LIchange.signed, data.long.change.perisylvian.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange1.post.control$LIchange.signed, data.long.change.perisylvian.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="spearman")


c("H0: 0 = mean of LIchange for perisylvian pre-to-followup intention participants :")
t.test(data.long.change.perisylvian.LIchange2.followup.intention$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.perisylvian.LIchange2.followup.intention$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange2.followup.intention$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.perisylvian.LIchange2.followup.intention$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange2.followup.intention$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")

c("H0: 0 = mean of LIchange for perisylvian pre-to-followup control participants :")
t.test(data.long.change.perisylvian.LIchange2.followup.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.perisylvian.LIchange2.followup.control$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.perisylvian.LIchange2.followup.control$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.perisylvian.LIchange2.followup.control$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.perisylvian.LIchange2.followup.control$LIchange.signed, data.long.change.perisylvian.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="pearson")

# ...for medialFrontal
c("H0: 0 = mean of LIchange for medial pre-to-post intention participants :")
t.test(data.long.change.medialFrontal.LIchange1.post.intention$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.medialFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.medialFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange1.post.intention$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")

c("H0: 0 = mean of LIchange for medialFrontal pre-to-post control participants :")
t.test(data.long.change.medialFrontal.LIchange1.post.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.medialFrontal.LIchange1.post.control$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange1.post.control$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.medialFrontal.LIchange1.post.control$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange1.post.control$LIchange.signed, data.long.change.medialFrontal.LIchange1.post.control$category.cstat.Z.post, alternative="two.sided", method="spearman")

c("H0: 0 = mean of LIchange for medialFrontal pre-to-followup intention participants :")
t.test(data.long.change.medialFrontal.LIchange2.followup.intention$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.medialFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.intention$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.medialFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange2.followup.intention$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.intention$category.cstat.Z.post, alternative="two.sided", method="spearman")

c("H0: 0 = mean of LIchange for medialFrontal pre-to-followup control participants :")
t.test(data.long.change.medialFrontal.LIchange2.followup.control$LIchange.signed, mu=0, alternative="two.sided")
cor.test(data.long.change.medialFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.control$naming.cstat.Z.post, alternative="two.sided", method="spearman")
cor.test(data.long.change.medialFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="pearson")
cor.test(data.long.change.medialFrontal.LIchange2.followup.control$LIchange.signed, data.long.change.medialFrontal.LIchange2.followup.control$category.cstat.Z.post, alternative="two.sided", method="spearman")








#########################################################################################################################
# print plots to multi-page PDF on letter paper in portrait orientation:
#pdf("/tmp/r01-plots.pdf", height=7, paper="letter")
pdf("/tmp/r01-plots.pdf", paper="letter")
# poster figures first:
print(p.lateralityChange)
print(p.corr.categories)
print(p.corr.naming)
# followed by everything else:
print(p.laterality)
#print(p.laterality.lateralFrontal)
#print(p.laterality.perisylvian)
#print(p.laterality.medialFrontal)
#print(p.lateralityChange.lateralFrontal)
#print(p.lateralityChange.perisylvian)
#print(p.lateralityChange.medialFrontal)
dev.off()

# view pdf in evince or acroread:
system("evince /tmp/r01-plots.pdf &")
