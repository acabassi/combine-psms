########################### Setting C: unsupervised ############################
cat("Setting D \n")

rm(list=ls())
library(klic)
library(mclust)

n_experiments <- 100
n_subsets <- 4
n_psms_per_subset <- 3
w_values <- c(0.2, 0.4, 0.6, 0.8)
P <- 10 # No extra covariates
N <- 300
uno <- rep(1, 50)
n_clusters <- 6
cluster_labels <- rep(1:n_clusters, each = 50)
weights <- array(NA, c(N, n_subsets, n_psms_per_subset, n_experiments))
ari_one <- matrix(NA, length(w_values), n_experiments)
ari_all <- matrix(NA, n_subsets, n_experiments)
subsets <- matrix(c(1,2,3,1,2,4,1,3,4,2,3,4),
                  nrow=n_subsets, ncol=n_psms_per_subset, byrow = TRUE)

for(experiment in 1:n_experiments){
  cat("Experiment", experiment, " ")
  psms <- array(NA, c(N, N, length(w_values)))
  count <- 0
  for(w in w_values){
    cat("w", w, " ")
    if(w!=0.8){
      load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm.RData"))
    }else{
      load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm_permuted.RData"))
    }
    count <- count + 1
    psm <- spectrumShift(psm)
    psms[,,count] <- psm
    output <- kkmeans(psm, parameters = list(cluster_count = n_clusters))
    ari_one[count,experiment] <-
      adjustedRandIndex(output$clustering, cluster_labels)
  }
  cat("\n")
}

save(ari_one,
     file = paste0("results/settingD_unsupervised_one.RData"))

for(experiment in 1:n_experiments){
  cat("Experiment", experiment, " ")
  psms <- array(NA, c(N, N, n_psms_per_subset))
  
  for(subset in 1:n_subsets){
    cat("Subset", subset, " ")
    w_values_in_subset <- subsets[subset,]
    for(count in 1:n_psms_per_subset){
      w <- w_values[w_values_in_subset[count]]
      if(w!=0.8){
        load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm.RData"))
      }else{
        load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm_permuted.RData"))
      }
      psm <- spectrumShift(psm)
      psms[,,count] <- psm
    }
    output <-
      lmkkmeans(psms,
                parameters = list(cluster_count = n_clusters,
                                  iteration_count = 100))
    weights[,subset,,experiment] <- output$Theta
    ari_all[subset,experiment] <-
      adjustedRandIndex(output$clustering, cluster_labels)
  }
  
  cat("\n")
}

save(ari_all, weights, file = "results/settingD_unsupervised.RData")

cat("Done")