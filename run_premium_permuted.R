################################################################################
################################## Run premium #################################
################################################################################

rm(list=ls())
library(klic)
library(PReMiuM)

### Experiment number
experiment <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

### Load settings (HPC)
args <- commandArgs(trailingOnly=TRUE)

### Value of w
w <-  as.integer(args[1])/10 # Must be 0.8

### Chain number
chain <- as.integer(args[2])

### Number of covariates
p  <-  as.integer(args[3])

### Load data
load(paste0("data/experiment", experiment, "_w", w*10, "_ncov", p, ".RData"))
load("data/permutation.RData")

n_covariates <- dim(data)[2]
outcome <- binary_outcome
data <- cbind(outcome, as.data.frame(data[permuted_observations,]))

############################### Fit using outcome ##############################

prof_regr <-profRegr(yModel="Bernoulli",
                    xModel="Discrete",
                    nSweeps=10000,
                    nClusInit=15,
                    nBurn=2000,
                    data=data,
                    output=paste0("premium/binary-outcome/experiment",
                                  experiment, "_w", w*10, "_ncov", p, "_chain",
                                  chain, "_permuted"),
                    covNames = paste0("Variable", seq(1,n_covariates)),
                    seed=12345)

save(prof_regr,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain,
                   "_output_prof_regr_permuted.RData"))

plot_heatmap = function(dissMat){
  heatmap(1 - dissMat, keep.dendro = FALSE, symm = TRUE, Rowv = NA, 
          labRow = FALSE, labCol = FALSE, margins = c(4.5, 4.5), 
          main = NULL, xlab = NULL, ylab = NULL)
}

dissimObj = PReMiuM::calcDissimilarityMatrix(prof_regr)
dissMat = PReMiuM::vec2mat(dissimObj$disSimMat, nrow = length(outcome))
psm <- 1-dissMat
coph_corr <- copheneticCorrelation(psm)

save(psm, coph_corr, binary_outcome,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain, "_psm_permuted.RData"))

############################ Fit excluding outcome #############################
prof_regr <-profRegr(yModel="Bernoulli",
                     xModel="Discrete",
                     nSweeps=10000,
                     nClusInit=15,
                     nBurn=2000,
                     data=data,
                     output=paste0("premium/binary-outcome/experiment",
                                   experiment, "_w", w*10, "_ncov", p, "_chain",
                                   chain, "_exclude_y_permuted"),
                     covNames = paste0("Variable", seq(1,n_covariates)),
                     excludeY = TRUE,
                     seed=12345)

save(prof_regr,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain,
                   "_output_prof_regr_exclude_y_permuted.RData"))


dissimObj = PReMiuM::calcDissimilarityMatrix(prof_regr)
dissMat = PReMiuM::vec2mat(dissimObj$disSimMat, nrow = length(outcome))
psm <- 1-dissMat
coph_corr <- copheneticCorrelation(psm)

save(psm, coph_corr, binary_outcome,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain,
                   "_psm_exclude_y_permuted.RData"))
