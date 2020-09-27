rm(list = ls())

### Load data 

data = list()

n_experiments = 100
n_obs = 300
# data_list = list()
response = c(rep(1,50), rep(2,50), rep(3,50), rep(4,50), rep(5,50), rep(6,50))

### Load PSMs

data = array(NA, c(n_obs, n_obs, 6, n_experiments))

for(i in 0:5){
  w = i*0.2
  for(j in 1:n_experiments){
    psm = read.csv("premium_output_psm.csv", header = FALSE)
    data[,,i+1,j] = matrix(unlist(psm), ncol = 300)
  }
}

setwd("~/Documents/combining-PSMs/synthetic-datasets/")
save(data, response, file = "allPSMs.RData")

### Load Datasets

n_var = 10

datasets = array(NA, c(n_obs, n_var, 6, n_experiments))

for(i in 0:5){
  w = i*0.2
  for(j in 1:n_experiments){
    load("data.RData")
    datasets[,,i+1,j] = as.matrix(categoricalData[2:11])
  }
}
      
setwd("~/Documents/combining-PSMs/synthetic-datasets/")           
save(datasets, response, file = "allDatasets.RData")

### Plot heatmaps of experiment 1

source("~/Documents/combining-PSMs/kernel-kmeans-examples/plot-heatmap.R")

setwd("~/Desktop/")
setEPS()
postscript("simulation_psm0.eps", width = 5, height = 5)
heatmap(1 - data[,,1,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

setEPS()
postscript("simulation_psm1.eps", width = 5, height = 5)
heatmap(1 - data[,,2,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

setEPS()
postscript("simulation_psm2.eps", width = 5, height = 5)
heatmap(1 - data[,,3,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

setEPS()
postscript("simulation_psm3.eps", width = 5, height = 5)
heatmap(1 - data[,,4,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

setEPS()
postscript("simulation_psm4.eps", width = 5, height = 5)
heatmap(1 - data[,,5,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

setEPS()
postscript("simulation_psm5.eps", width = 5, height = 5)
heatmap(1 - data[,,6,1], keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
        labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
        main = NULL, xlab = NULL, ylab = NULL)
dev.off()

# provo con un ggplot - no, non funziona!
# library(ggplot2)
# psm1 <- data[,,1,1]
# psm1 <- t(psm1)
# library(reshape2)
# melted_psm1 <- melt(psm1)
# colnames(melted_psm1) <- c(NULL, NULL, "Similarity")
# ggplot(data = melted_psm1, aes(x=Var1, y=Var2, fill=value)) + geom_tile() + scale_fill_gradient(low = "white", high = "steelblue")

palette_ggcorrplot = c("#6D9EC1", "white", "#E46726")

library(ggcorrplot)
setEPS()
postscript("simulation-psm1.eps", width = 5, height = 5)
ggcorrplot(psm1, hc.order = FALSE,
           outline.col = "white",
           ggtheme = ggplot2::theme_gray,
           colors = c(palette_ggcorrplot, palette_ggcorrplot, palette_ggcorrplot),
           show.legend = FALSE)

source("~/Documents/combining-PSMs/lmkkmeans-R/kkmeans_train.R")
library(mclust)

parameters = list()
parameters$cluster_count = 6

### Kernel k-means
ari_kme = matrix(NA, 6, 100)
for(i in 1:6){
  for(j in 1:100){
    state = kkmeans_train(data[,,i,j], parameters)
    ari_kme[i,j] = adjustedRandIndex(state$clustering, response)
  }
}
par(mfrow=c(2,3))
hist(ari_kme[1,], main = "w = 0",   xlab = "ARI")
hist(ari_kme[2,], main = "w = 0.2", xlab = "ARI")
hist(ari_kme[3,], main = "w = 0.4", xlab = "ARI")
hist(ari_kme[4,], main = "w = 0.6", xlab = "ARI")
hist(ari_kme[5,], main = "w = 0.8", xlab = "ARI")
hist(ari_kme[6,], main = "w = 1",   xlab = "ARI")

