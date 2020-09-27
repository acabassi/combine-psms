########################### Setting A: unsupervised ############################
cat("Summarising PSMs using kernel k-means and silhouette \n")

rm(list=ls())
library(coca)
library(klic)
library(mclust)

n_experiments <- 100
w_values <- c(0.2, 0.4, 0.6, 0.8)
P <- 10 # No extra covariates
N <- 300
uno <- rep(1, 50)
n_clusters <- 6
cluster_labels <- rep(1:n_clusters, each = 50)
ari_one <- matrix(NA, length(w_values), n_experiments)
maxK <- 20

for(experiment in 1:n_experiments){
  cat("Experiment", experiment, " ")
  psms <- array(NA, c(N, N, length(w_values)))
  count <- 0
  for(w in w_values){
    cat("w", w, " ")
    load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov", P,
                "_chain", 1, "_psm_exclude_y.RData"))
    count <- count + 1
    psm <- spectrumShift(psm)
    psms[,,count] <- psm
    cl_labels <- array(NA, c(maxK-1, N))
    psm_repeated <- array(NA, c(N, N, maxK-1))
    for(k in 2:maxK){
      psm_repeated[,,k-1] <- psm
      cl_labels[k-1,]  <-
        kkmeans(psm, parameters = list(cluster_count = k))$clustering
    }
    selected_k <- maximiseSilhouette(psm_repeated, cl_labels, maxK = maxK)$K
    ari_one[count,experiment] <-
      adjustedRandIndex(cl_labels[selected_k-1,], cluster_labels)
  }
  cat("\n")
}

ari_silhouette <- ari_one
save(ari_silhouette, file = "results/summarising_PSMs_silhouette.RData")
