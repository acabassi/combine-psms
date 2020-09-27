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


load("results/binary-outcome/settingA_ari.RData")
ari_a <- ari; rm(ari)

load("results/binary-outcome/settingB_ari_10_var_sel.RData")
ari_b <- ari; rm(ari)

load("results/binary-outcome/settingC_ari.RData")
ari_c <- ari; rm(ari)

load("results/binary-outcome/settingD_ari.RData")
ari_d <- ari; rm(ari)

ari <- abind(ari_a, ari_b, ari_c, ari_d, along = 4)

ari.m <- melt(ari)    

ari.m[ari.m$Var4 ==1,]$Var4 <- "Setting A"
ari.m[ari.m$Var4 ==2,]$Var4 <- "Setting B"
ari.m[ari.m$Var4 ==3,]$Var4 <- "Setting C"
ari.m[ari.m$Var4 ==4,]$Var4 <- "Setting D"

head(ari.m)
colnames(ari.m) <- c("Dataset","Experiment", "Method", "Setting", "ARI")

ari.m$Dataset <- replace(ari.m$Dataset, ari.m$Dataset == "1", "0")
ari.m$Dataset <- replace(ari.m$Dataset, ari.m$Dataset == "2", "1")
ari.m$Dataset <- replace(ari.m$Dataset, ari.m$Dataset == "3", "2")
ari.m$Dataset <- replace(ari.m$Dataset, ari.m$Dataset == "4", "3")

ari.m[intersect(which(ari.m$Dataset == 0),
                which(ari.m$Method!="One PSM")),]$Dataset <- "0+1+2" 
ari.m[intersect(which(ari.m$Dataset == 1),
                which(ari.m$Method!="One PSM")),]$Dataset <- "0+1+3" 
ari.m[intersect(which(ari.m$Dataset == 2),
                which(ari.m$Method!="One PSM")),]$Dataset <- "0+2+3" 
ari.m[intersect(which(ari.m$Dataset == 3),
                which(ari.m$Method!="One PSM")),]$Dataset <- "1+2+3" 

ari.m$Dataset <- factor(ari.m$Dataset,
                        levels = c("0", "1", "2", "3",
                                   "0+1+2",  "0+1+3", "0+2+3",  "1+2+3"),
                        ordered = TRUE)

ggplot(data = ari.m, aes(x=Dataset, y=ARI, fill = Dataset)) +
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) + my_theme_rotated_labels +
  facet_grid( Setting~Method, scales ="free") +
  scale_fill_manual(values=ari_palette)
ggsave(paste0("figures/binary-outcome/ari-binary-outcome.pdf"),
       device = "pdf", width = 14.8, height = 18.5,
       units = "cm")
