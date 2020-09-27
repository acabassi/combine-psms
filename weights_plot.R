rm(list=ls())

library(abind)
library(ggplot2)
library(reshape2)

# Define ggplot2 theme 
my_theme_rotated_labels <- theme(
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_line(colour = "grey50"),
  panel.grid.major.x = element_blank() ,
  panel.grid.major.y = element_line(size=.1, color="black"),
  axis.ticks.y = element_blank(),
  axis.ticks.x = element_blank(),
  axis.text.x = element_text(angle = 90, hjust = 1),
  legend.position = "none",
  axis.title.x=element_blank()
)

ari_palette <- c("#86C6FE", # Super light blue, 
                 "#6CACE4", # Light blue 
                 "#0072ce", # Core blue
                 "#003C71", # Dark blue
                 "#E89CAE", # Light pink
                 "#F1BE48", # Light yellow
                 "#B7BF10", # Light green
                 "#85b09A") # Light Cambridge blue

load("results/true-cl-labels/settingA_weights.RData")
weights_a <- weights; rm(weights)

load("results/true-cl-labels/settingB_weights_10_var_sel.RData")
weights_b <- weights; rm(weights)

load("results/true-cl-labels/settingC_weights.RData")
weights_c <- weights; rm(weights)

load("results/true-cl-labels/settingD_weights.RData")
weights_d <- weights; rm(weights)

weights_unsupervised <- abind(weights_a[,,,"Unsupervised integration"],
                              weights_b[,,,"Unsupervised integration"],
                              weights_c[,,,"Unsupervised integration"],
                              weights_d[,,,"Unsupervised integration"],
                              along = 4)

weights_outcomeguided <- abind(weights_a[,,,"Outcome-guided integration"],
                               weights_b[,,,"Outcome-guided integration"],
                               weights_c[,,,"Outcome-guided integration"],
                               weights_d[,,,"Outcome-guided integration"],
                               along = 4)

weights.m <- melt(weights_outcomeguided) # Either weights_unsupervised
                                        # or weights_outcomeguided

weights.m[weights.m$Var4 ==1,]$Var4 <- "Setting A"
weights.m[weights.m$Var4 ==2,]$Var4 <- "Setting B"
weights.m[weights.m$Var4 ==3,]$Var4 <- "Setting C"
weights.m[weights.m$Var4 ==4,]$Var4 <- "Setting D"

head(weights.m)
colnames(weights.m) <- c("Subset", "Rank", "Experiment", "Setting", "Weight")
weights.m$Dataset <- rep(0, 2400)

weights.m[intersect(which(weights.m$Rank == "1st"),
                    which(weights.m$Subset!="2+3+4")),]$Dataset <- "1" 
weights.m[intersect(which(weights.m$Rank == "2nd"),
                    which(weights.m$Subset=="1+2+3" |
                            weights.m$Subset == "1+2+4")),]$Dataset <- "2" 
weights.m[intersect(which(weights.m$Rank == "1st"),
                    which(weights.m$Subset=="2+3+4")),]$Dataset <- "2"
weights.m[intersect(which(weights.m$Rank == "3rd"),
                    which(weights.m$Subset!="1+2+3")),]$Dataset <- "4" 
weights.m[which(weights.m$Dataset ==0),]$Dataset <- "3" 


ggplot(data = weights.m, aes(x=Dataset, y=Weight, fill = Dataset)) + 
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) +
  my_theme_rotated_labels +
  facet_grid(Setting ~ Subset, scales ="free") +
  scale_fill_manual(values=ari_palette)
ggsave(paste0("figures/true-cl-labels/weights-outcomeguided.jpg"),
       device = "jpeg", width = 16, height = 20,
       units = "cm")
