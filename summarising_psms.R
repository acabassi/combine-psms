############################### Summarising PSMs ###############################

rm(list=ls())
library(mcclust)
library(mclust)

n_experiments <- 100
w_values <- c(0.2, 0.4, 0.6, 0.8)
possible_n_covariates <- c(10, 12, 15, 20)
n_clusters <- 6
cluster_labels <- rep(1:n_clusters, each =50)

ari_avg_6 <- ari_avg_20 <- ari_comp_6 <- ari_comp_20 <- ari_draws <- 
  array(NA, c(n_experiments, length(w_values), length(possible_n_covariates)))

for(experiment in 1:n_experiments){
  w_count <- 0
  
  for(w in w_values){
    w_count <- w_count + 1
    ncov_count <- 0
    
    for(n_covariates in possible_n_covariates){
      ncov_count <- ncov_count + 1
      
      load(paste0("premium/experiment", experiment, "_w", w*10, "_ncov",
                n_covariates, "_chain", 1,"_psm_exclude_y.RData"))
      
      Z <- read.table(paste0("premium/experiment", experiment, "_w", w*10,
                      "_ncov", n_covariates,"_chain", 1,"_exclude_y_z.txt"))
      Z <- matrix(unlist(Z), ncol = length(Z[[1]]), byrow = TRUE)
      cl_draws <- maxpear(psm, cls.draw = t(Z), method = "draws")
      
      # Compute clusterings
      cl_avg_6 <- maxpear(psm, method = "avg", max.k = 6)
      cl_avg_20 <- maxpear(psm, method = "avg", max.k = 20)
      cl_comp_6 <- maxpear(psm, method = "comp", max.k = 6)
      cl_comp_20 <- maxpear(psm, method = "comp", max.k = 20)
    
      # Compute ARI
      ari_avg_6[experiment, w_count, ncov_count] <-
        adjustedRandIndex(cl_avg_6$cl, cluster_labels)
      ari_avg_20[experiment, w_count, ncov_count] <- 
        adjustedRandIndex(cl_avg_20$cl, cluster_labels)
      ari_comp_6[experiment, w_count, ncov_count] <-
        adjustedRandIndex(cl_comp_6$cl, cluster_labels)
      ari_comp_20[experiment, w_count, ncov_count] <-
        adjustedRandIndex(cl_comp_20$cl, cluster_labels)
      ari_draws[experiment, w_count, ncov_count] <- 
	      adjustedRandIndex(cl_draws$cl, cluster_labels)
    }
  }
}

save(ari_avg_6, ari_avg_20, ari_comp_6, ari_comp_20, ari_draws,
     file = "results/summarising_psms_max_pear.RData")

