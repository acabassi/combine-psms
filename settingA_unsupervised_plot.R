########################### Setting A: unsupervised ############################

rm(list=ls())
library(ggplot2)
library(reshape2)

# Define ggplot2 theme 
my_basic_theme <-  theme(
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_line(colour = "grey50"),
  panel.grid.major.x = element_blank() ,
  panel.grid.major.y = element_line(size=.1, color="black"),
  axis.ticks.y = element_blank(),
  axis.ticks.x = element_blank()
)

my_theme_rotated_labels <- theme(
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_line(colour = "grey50"),
  panel.grid.major.x = element_blank() ,
  panel.grid.major.y = element_line(size=.1, color="black"),
  axis.ticks.y = element_blank(),
  axis.ticks.x = element_blank(),
  axis.text.x = element_text(angle = 90, hjust = 1)
)

### Load results
load("results/settingA_unsupervised.RData")
load("results/summarising_PSMs.RData")

### Plot ARI
ari <- t(rbind(ari_one, ari_all))
colnames(ari) <- c("1", "2", "3", "4", "1+2+3", "1+2+4", "1+3+4", "2+3+4")

ari.m <- melt(ari)             
head(ari.m)
colnames(ari.m) <- c("Experiment", "Datasets", "ARI")
ari.m$Datasets <- factor(ari.m$Datasets,
                         levels = c("1", "2", "3", "4",
                                    "1+2+3", "1+2+4", "1+3+4", "2+3+4"),
                         ordered = TRUE)

ggplot(data = ari.m, aes(x=Datasets, y=ARI)) +
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) + my_theme_rotated_labels +
ggsave(paste0("figures/ari-a.jpg"),
       device = "jpeg", width = 7, height = 8,
       units = "cm")

### PLot weights

weights <- apply(weights, c(2,3,4), "mean")
rownames(weights) <- c("1+2+3", "1+2+4", "1+3+4", "2+3+4")
colnames(weights) <- c("1st", "2nd", "3rd")
weights.m <- melt(weights)
head(weights.m)
colnames(weights.m) <- c("Subset", "Dataset", "Experiment", "Weight")
ggplot(data = weights.m, aes(x=Dataset, y=Weight)) + 
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) +  my_theme_rotated_labels +
  facet_grid(cols=vars(Subset))
ggsave(paste0("figures/weights-a.jpg"),
       device = "jpeg", width = 7, height = 8,
       units = "cm")

