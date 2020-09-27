################################################################################
######################### Generate synthetic datasets ##########################
################################################################################

library(gplots)
library(PReMiuM)

rm(list = ls())
set.seed(1)

### Datasets with different levels of noise

alpha <- 0.01

clusSummary                  <- clusSummaryBernoulliDiscrete()
clusSummary$nFixedEffects    <- 0
clusSummary$clusterSizes     <- c(50, 50, 50, 50, 50, 50)
clusSummary$nCategories      <- c(3,  3,  3,  3,  3,  3)
clusSummary$nClusters        <- 6
clusSummary$clusterData[[6]] <- clusSummary$clusterData[[5]]

# Probabilities of being a case (1 per cluster)
# bernoulliParameters <- c(0.01, 0.15, 0.4, 0.6, 0.85, 0.99)
bernoulliParameters <- c(0.01, 0.1, 0.15, 0.85, 0.9, 0.99)
bernoulliParameters <-
  log(bernoulliParameters / (1 - bernoulliParameters))

### Experiment
for (experiment in seq(1, 100)){
  ### w
  for (w in c(0, 0.2, 0.4, 0.6, 0.8, 1)){
    ### Number of covariates
    for (p in c(10)){ #c(1, 2, 5, 10, 20, 35, 50))

      clusSummary$nCovariates <- p
      
      #put together the cluster data
      ##############################
      for (k in seq(1, clusSummary$nClusters))
        ### Cluster
      {
        currentCluster       <- clusSummary$clusterData[[k]]
        currentCluster$theta <- bernoulliParameters[k]
        
        for (j in seq(1, clusSummary$nCovariates))
        {
          x              <- rgamma(3, alpha)
          x              <- x / sum(x)
          x              <- w * x + (1 - w) * c(1, 1, 1) / 3
          x              <- x / sum(x)
          
          currentCluster$covariateProbs[[j]] <- x
        }
        
        clusSummary$clusterData[[k]] <- currentCluster
      }
      
      inputs <- generateSampleDataFile(clusSummary)
      
      data <- inputs$inputData[, -1]
      binary_outcome <- inputs$inputData[, 1]
      # save(file = paste0("data/experiment", experiment, "_w", w*10,
      #                         "_ncov", p, ".RData"),
      #           data, binary_outcome)
    }
  }
}

# pdf("dataVisualisation.pdf")
heatmap.2(as.matrix(inputs$inputData), dendrogram="none",
key.par=list(mar=c(3.5,1,3,4.7)),Colv = FALSE, Rowv = FALSE,
density.info = "none",lmat=rbind( c(0, 3), c(2,1), c(0,4) ),
lhei=c(0.5, 4, 1 ), key.title = "", trace = "none")
# dev.off()

######################### Datasets with nested clusters ########################
#       
# alpha <- 0.01
# 
# clusSummary                  <- clusSummaryBernoulliDiscrete()
# clusSummary$nFixedEffects    <- 0
# clusSummary$clusterSizes     <- c(100, 100, 100)
# clusSummary$nCategories      <- c( 3,  3,  3,  3,  3,  3)
# clusSummary$nClusters        <- 3
# clusSummary$clusterData[[6]] <- clusSummary$clusterData[[5]]
# 
# # Probabilities of being a case (1 per cluster)
# bernoulliParameters <- c(0.01, 0.4, 0.85) 
# bernoulliParameters <- log(bernoulliParameters/(1-bernoulliParameters))
# 
# for(experiment in seq(1,100)) ### Experiment
# {
#   for(w in c(0.8)) ### w
#  {
#     print(paste("w =", w))
#     for(p in c(10))#c(1, 2, 5, 10, 20, 35, 50)) ### Number of covariates (fixed! p = 10)
#     {
# #   p = 10
# #   crashes for p = 1000 (!)
#   print(paste("p =", p))
#   clusSummary$nCovariates <- p
#   # put together the cluster data 
#   ##############################
#   for (k in seq(1, clusSummary$nClusters)) ### Cluster
#     {
#     currentCluster       <- clusSummary$clusterData[[k]]
#     currentCluster$theta <- bernoulliParameters[k]
# 
#     for (j in seq(1, clusSummary$nCovariates ))
#       {
#       x              <- rgamma(3, alpha)
#       x              <- x/sum(x)
#       x              <- w*x + (1-w)*c(1,1,1)/3
#       x              <- x/sum(x)
#   
#       currentCluster$covariateProbs[[j]] <- x
#       }
# 
#       clusSummary$clusterData[[k]] <- currentCluster
#     }
# 
#     inputs     <- generateSampleDataFile(clusSummary)
#     
# #   pdf("dataVisualisation.pdf")
# #
#     heatmap.2(as.matrix(inputs$inputData[,-1]), dendrogram="none",
#     key.par=list(mar=c(3.5,1,3,4.7)),Colv = FALSE, Rowv = FALSE,
#     density.info = "none",lmat=rbind( c(0, 3), c(2,1), c(0,4) ),
#     lhei=c(0.5, 4, 1 ), key.title = "", trace = "none")
# #   dev.off()
# 
#     write.csv(file = "data.csv", inputs$inputData[,-1])
#    }
#  }
# }
