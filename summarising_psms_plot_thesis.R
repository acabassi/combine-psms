############################### Summarising PSMs ###############################
##################################### Plot #####################################

rm(list=ls())
library(abind)
library(ggplot2)
library(reshape2)

# Define ggplot2 theme 
my_theme_with_legend <- theme(
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_line(colour = "grey50"),
  panel.grid.major.x = element_blank() ,
  panel.grid.major.y = element_line(size=.1, color="black"),
  axis.ticks.y = element_blank(),
  axis.ticks.x = element_blank(),
  axis.text.x = element_blank(),
  axis.title.x = element_blank(),
  legend.position = "bottom",
  legend.title=element_blank()
)

### Load results
load("results/true-cl-labels/summarising_psms.RData")
load("results/true-cl-labels/summarising_PSMs_silhouette.RData")
load("results/true-cl-labels/summarising_psms_min_vi.RData")
ari_avg_6_vi <- ari_avg_6
ari_avg_20_vi <- ari_avg_20
ari_comp_6_vi <- ari_comp_6
ari_comp_20_vi <- ari_comp_20
ari_draws_vi <- ari_draws
load("results/true-cl-labels/summarising_psms_max_pear.RData")

### 10 covariates ###
ari_w2 <- cbind(ari_avg_6[,1,1], ari_avg_20[,1,1],
                ari_comp_6[,1,1], ari_comp_20[,1,1],
                ari_draws[,1,1],
                ari_avg_6_vi[,1,1], ari_avg_20_vi[,1,1],
                ari_comp_6_vi[,1,1], ari_comp_20_vi[,1,1],
                ari_draws_vi[,1,1],
                t(ari_one)[,1], t(ari_silhouette)[,1])
ari_w4 <- cbind(ari_avg_6[,2,1], ari_avg_20[,2,1],
                ari_comp_6[,2,1], ari_comp_20[,2,1],
                ari_draws[,2,1],
                ari_avg_6_vi[,2,1], ari_avg_20_vi[,2,1],
                ari_comp_6_vi[,2,1], ari_comp_20_vi[,2,1],
                ari_draws_vi[,2,1],
                t(ari_one)[,2], t(ari_silhouette)[,2])
ari_w6 <- cbind(ari_avg_6[,3,1], ari_avg_20[,3,1],
                ari_comp_6[,3,1], ari_comp_20[,3,1],
                ari_draws[,3,1],
                ari_avg_6_vi[,3,1], ari_avg_20_vi[,3,1],
                ari_comp_6_vi[,3,1], ari_comp_20_vi[,3,1],
                ari_draws_vi[,3,1],
                t(ari_one)[,3], t(ari_silhouette)[,3])
ari_w8 <- cbind(ari_avg_6[,4,1], ari_avg_20[,4,1],
                ari_comp_6[,4,1], ari_comp_20[,4,1],
                ari_draws[,4,1],
                ari_avg_6_vi[,4,1], ari_avg_20_vi[,4,1],
                ari_comp_6_vi[,4,1], ari_comp_20_vi[,4,1],
                ari_draws_vi[,4,1],
                t(ari_one)[,4], t(ari_silhouette)[,4])

ari <- abind(ari_w2, ari_w4, ari_w6, ari_w8, along = 3)
dimnames(ari) <- list(as.character(1:100),
                      c("MaxPEAR ''avg'' 6",
                        "MaxPEAR ''avg'' 20",
                        "MaxPEAR ''comp' 6",
                        "MaxPEAR ''comp'' 20",
                        "MaxPEAR ''draws''",
                        "MinVI ''avg'' 6",
                        "MinVI ''avg'' 20",
                        "MinVI ''comp'' 6",
                        "MinVI ''comp'' 20",
                        "MinVI ''draws''",
                        "k-means K=6",
                        "k-means silhouette"),
                      c("w = 0.2", "w = 0.4", "w = 0.6", "w = 0.8"))

### Plot ARI
ari.m <- melt(ari)             
head(ari.m)
colnames(ari.m) <- c("Experiment", "Method", "Separation", "ARI")

bigPalette <- c("#B7BF10", # Light green
                "#4E5B31", # Core green
                "#115E67",# Core Cambridge blue
                "#85b09A", # Light Cambridge blue
                "#0072ce", # Core blue
                "#6CACE4", # Light blue
                "#E89CAE", # Light pink
                "#af95a6", # Light purple
                "#8C77A3",# Modified core purple
                "#D50032", # Core red
                "#E87722",  # Core orange
                "#F1BE48") # Light yellow

ggplot(data = ari.m, aes(x=Method, y=ARI, fill = Method)) +
  geom_boxplot(outlier.size = 0.3) + ylim(0,1) + my_theme_with_legend +
  facet_grid(. ~ Separation ) +  #+guides(fill=guide_legend(nrow=3,byrow=TRUE))
  scale_fill_manual(values=bigPalette)
ggsave(paste0("figures/true-cl-labels/summarising-psms-thesis-plot.pdf"),
         device = "pdf", width = 16.5, height = 10,
         units = "cm")

