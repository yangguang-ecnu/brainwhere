# r commands for creating plots of R01 data:

library(ggplot2)
library(plyr)
library(reshape2)

# import csv and double-check it:
data.long<-(read.csv("/tmp/r01_li_long.csv"))
head(data.long)
str(data.long)
summary(data.long)

# calculate LI and spot-check. Results in NaN when dividing by zero
data.long <- transform(data.long, LI=(ulLeft-ulRight)/(ulLeft+ulRight))
head(data.long)
summary(data.long)
# ^^ notice NA's in LI summary

# change factor level "3mo" to "followup" for better naming
levels(data.long$session)
levels(data.long$session)[levels(data.long$session)=="3mo"]<-"followup"
levels(data.long$session)
# and also order session levels:
data.long$session <- factor(data.long$session, levels=c("pre","post","followup"))

# before plotting coord_flip'd LI plot, improve ordering for display in faceted flipped axes
data.long$participant<-factor(data.long$participant,levels=rev(levels(data.long$participant)))
data.long$group<-factor(data.long$group, levels=rev(levels(data.long$group)))
data.long$roi<-factor(data.long$roi, levels=c("CROSSONlateralFrontalROI","CROSSONPerisylvian","CROSSONmedialFrontal"))

# and finally create bar plot with x and y axes flipped. Notice negative dodging to get pre/post/3mo order correct:
# display brewer palettes to view color options: RColorBrewer::display.brewer.all
p.laterality<-ggplot(data.long, aes(participant, LI, fill=session)) + geom_bar(stat="identity", position=position_dodge(width=-.75)) + coord_flip() + facet_grid(roi ~ group, space="free") + scale_y_reverse() + scale_fill_brewer(palette="YlOrRd") + theme_bw() + ylab("Laterality Index")


# also eventually try with geom_point + geom_segment

# more factor ordering help:
# reorder()
# refactor()

#subset the data if needed
#data.long.sub<-subset(data.long,roi == "CROSSONlateralFrontalROI" & group == "intention")



# now pivot data to wide format for calculation of LIchange1 and LIchange2
data.wide <- dcast(data.long, participant + group + roi ~ session, value_var="LI")

str(data.wide)
summary(data.wide)

# calculate LIchange1 and LIchange2
data.wide <- transform(data.wide, LIchange1.post=(post-pre))
data.wide <- transform(data.wide, LIchange2.followup=(followup-pre))

# melt data for plotting and fix resulting variable names
data.long.change<-melt(data.wide, id.vars=c("participant","group","roi"), measure.vars=c("LIchange1.post","LIchange2.followup"), variable.name=c("LIchange.signed"))
head(data.long.change)
names(data.long.change)[names(data.long.change)=="variable"]<-"LIchange.period"
names(data.long.change)[names(data.long.change)=="value"]<-"LIchange.signed"
summary(data.long.change)

# plot
p.lateralityChange<-ggplot(data.long.change, aes(participant, LIchange.signed, fill=LIchange.period)) + geom_bar(stat="identity", position=position_dodge(width=-.75)) + coord_flip() + facet_grid(roi ~ group) + scale_y_reverse() + scale_fill_brewer(palette="Blues") + theme_bw() + ylab("Signed Change in Laterality Index")

# print plots to multi-page PDF on letter paper in portrait orientation:
pdf("/tmp/r01-plots.pdf", height=9, paper="letter")
print(p.laterality)
print(p.lateralityChange)
dev.off()

