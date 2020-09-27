########################### Setting A: unsupervised ############################

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

### Load results
load(paste0("results/binary-outcome/settingC_unsupervised.RData"))
ari_un <- ari_all; rm(ari_all)
weights_un <- weights; rm(weights)
load(paste0("results/binary-outcome/settingC_outcomeguided.RData"))
ari_og <- ari_all; rm(ari_all)
weights_og <- weights; rm(weights)
load(paste0("results/binary-outcome/settingC_unsupervised_one.RData"))

### Plot ARI
ari <- abind(ari_one, ari_un, ari_og, along = 3)
dimnames(ari) <- list(as.character(1:4),
                      as.character(1:100),
                      c("One PSM",
                        "Unsupervised integration",
                        "Outcome-guided integration"))
save(ari, file = "results/binary-outcome/settingC_ari.RData")

ari.m <- melt(ari)             
head(ari.m)
colnames(ari.m) <- c("Dataset","Experiment", "Method", "ARI")
ari.m[intersect(which(ari.m$Dataset == 1),
                which(ari.m$Method!="One PSM")),]$Dataset <- "1+2+3" 
ari.m[intersect(which(ari.m$Dataset == 2),
                which(ari.m$Method!="One PSM")),]$Dataset <- "1+2+4" 
ari.m[intersect(which(ari.m$Dataset == 3),
                which(ari.m$Method!="One PSM")),]$Dataset <- "1+3+4" 
ari.m[intersect(which(ari.m$Dataset == 4),
                which(ari.m$Method!="One PSM")),]$Dataset <- "2+3+4" 

ari.m$Dataset <- factor(ari.m$Dataset,
                        levels = c("1", "2", "3", "4",
                                   "1+2+3",  "1+2+4", "1+3+4",  "2+3+4"),
                        ordered = TRUE)

ggplot(data = ari.m, aes(x=Dataset, y=ARI, fill = Dataset)) +
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) + my_theme_rotated_labels +
  facet_wrap( .~Method, scales ="free") +
  scale_fill_manual(values=ari_palette)
ggsave(paste0("figures/binary-outcome/ari-c-outcomeguided.jpg"),
       device = "jpeg", width = 16, height = 6,
       units = "cm")

### PLot weights

weights_un <- apply(weights_un, c(2,3,4), "mean")
rownames(weights_un)  <- c("1+2+3", "1+2+4", "1+3+4", "2+3+4")
colnames(weights_un) <- c("1st", "2nd", "3rd")

weights_og <- aperm(weights_og, c(3,1,2))
rownames(weights_un)  <- c("1+2+3", "1+2+4", "1+3+4", "2+3+4")
colnames(weights_un) <- c("1st", "2nd", "3rd")

weights <- abind(weights_un, weights_og, along = 4)
dimnames(weights)[4][[1]] <- c("Unsupervised integration",
                               "Outcome-guided integration")
save(weights, file = "results/binary-outcome/settingC_weights.RData")

weights.m <- melt(weights)
head(weights.m)
colnames(weights.m) <- c("Subset", "Rank", "Experiment", "Method", "Weight")
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
  facet_grid(Method ~ Subset, scales = "free") +
  scale_fill_manual(values=ari_palette)
ggsave(paste0("figures/binary-outcome/weights-c-outcomeguided.jpg"),
       device = "jpeg", width = 16, height = 12,
       units = "cm")
