################################################################################
######################### Generate synthetic datasets ##########################
################################################################################

library(circlize)
library(ComplexHeatmap)
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
    for (p in c(12, 15, 20)){

      clusSummary$nCovariates <- p
      
      #put together the cluster data
      ##############################
      for (k in seq(1, clusSummary$nClusters))
        ### Cluster
      {
        currentCluster       <- clusSummary$clusterData[[k]]
        currentCluster$theta <- bernoulliParameters[k]
        
        for (j in seq(1, 10)){
          x              <- rgamma(3, alpha)
          x              <- x / sum(x)
          x              <- w * x + (1 - w) * c(1, 1, 1) / 3
          x              <- x / sum(x)
          
          currentCluster$covariateProbs[[j]] <- x
        }
        for(j in seq(11, clusSummary$nCovariates)){
          currentCluster$covariateProbs[[j]] <- c(1/3, 1/3, 1/3)
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

my_anno_legend_param <- function(name, nrow=1) {
  return(list(
    title = name,
    labels_gp = gpar(fontsize = 16),
    title_gp = gpar(fontsize = 16),
    nrow = nrow,
    direction = "horizontal",
    grid_height = unit(5, "mm"),
    grid_width = unit(5, "mm")
  ))
}

my_heatmap_legend_param <- list(labels_gp = gpar(fontsize = 16),
                                title_gp = gpar(fontsize = 16),
                                grid_height = unit(5, "mm"),
                                grid_width = unit(5, "mm"))

data_for_plot <- as.matrix(inputs$inputData)

Hresponse <- rowAnnotation(Response = data_for_plot[,1],
                           name = "Response",
                           show_annotation_name = FALSE,
                           annotation_legend_param =
                             my_anno_legend_param("Response", 2),
                           col = list(Response = c("0"="#B7BF10",
                                                   "1"="#F1BE48")))

palette <- colorRampPalette(c("#D55E00", "white", "#0072B2"))(8)

Hdata <- Heatmap(data_for_plot,
                 cluster_rows = FALSE,
                 cluster_columns = FALSE,
                 show_row_names = FALSE,
                 show_column_names = FALSE,
                 row_split = rep(1:6, each=50),
                 row_gap = unit(2, "mm"),
                 name = "Data",
                 heatmap_legend_param = my_heatmap_legend_param,
                 col = c("0"=palette[2], "1"="white", "2"=palette[7]))

pdf(
  paste0("figures/data.pdf"),
  height = 6,
  width = 9
)
Hdata + Hresponse
dev.off()

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
