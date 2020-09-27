########################### Setting B: unsupervised ############################
cat("Setting B \n")

rm(list=ls())
library(klic)
library(mclust)
library(R.matlab)

n_extra_covariates <- 10 # Can be 2, 5, 10
cat(n_extra_covariates, "extra covariates \n")
n_experiments <- 100
n_subsets <- 4
n_psms_per_subset <- 3
w_values <- c(0.2, 0.4, 0.6, 0.8)
P <- 10 + n_extra_covariates
N <- 300
uno <- rep(1, 50)
n_clusters <- 6
cluster_labels <- rep(1:n_clusters, each =50)
subsets <- matrix(c(1,2,3,1,2,4,1,3,4,2,3,4),
                  nrow=n_subsets, ncol=n_psms_per_subset, byrow = TRUE)

########################## Without variable selection ##########################
cat("***** Without variable selection *****")

weights <- readMat(paste0("results/binary-outcome/settingB_outcomeguided_weights_",
                          n_extra_covariates,
                          "extracov_without_var_sel.mat"))$all.betas

ari_all <- matrix(NA, n_subsets, n_experiments)

for(experiment in 1:n_experiments){
  cat("Experiment", experiment, " ")
  weighted_psm <- array(0, c(N, N))
  
  for(subset in 1:n_subsets){
    cat("Subset", subset, " ")
    w_values_in_subset <- subsets[subset,]
    for(count in 1:n_psms_per_subset){
      w <- w_values[w_values_in_subset[count]]
      load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm_exclude_y.RData"))
      psm <- spectrumShift(psm)
      weighted_psm <- weighted_psm + weights[count, experiment, subset]
    }
    output <-
      kkmeans(weighted_psm, parameters = list(cluster_count = n_clusters))
    ari_all[subset,experiment] <-
      adjustedRandIndex(output$clustering, cluster_labels)
  }
  
  cat("\n")
}

save(ari_all, weights, file = paste0("results/binary-outcome/settingB_outcomeguided_",
     n_extra_covariates,"_without_var_sel.RData"))

############################ With variable selection ###########################
cat("***** With variable selection *****")

weights <- readMat(paste0("results/binary-outcome/settingB_outcomeguided_weights_",
                          n_extra_covariates,
                          "extracov_var_sel.mat"))$all.betas
ari_all <- matrix(NA, n_subsets, n_experiments)

for(experiment in 1:n_experiments){
  cat("Experiment", experiment, " ")
  weighted_psm <- array(0, c(N, N))

  for(subset in 1:n_subsets){
    cat("Subset", subset, " ")
    w_values_in_subset <- subsets[subset,]
    for(count in 1:n_psms_per_subset){
      w <- w_values[w_values_in_subset[count]]
      load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10, "_ncov", P,
                  "_chain", 1, "_psm_exclude_y_var_sel.RData"))
      psm <- spectrumShift(psm)
      weighted_psm <- weighted_psm + weights[count, experiment, subset] * psm
    }
    output <-
      kkmeans(weighted_psm, parameters = list(cluster_count = n_clusters))
    ari_all[subset,experiment] <-
      adjustedRandIndex(output$clustering, cluster_labels)
  }

  cat("\n")
}

save(ari_all, weights,
     file = paste0("results/binary-outcome/settingB_outcomeguided_", n_extra_covariates,
                   "_var_sel.RData"))
cat("Done")
