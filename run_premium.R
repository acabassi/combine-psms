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
w <-  as.integer(args[1])/10 # Must be one of c(0, 0.2, 0.4, 0.6, 0.8, 1))

### Chain number
chain <- as.integer(args[2])

### Number of covariates
p  <-  as.integer(args[3])

### Load data
load(paste0("data/experiment", experiment, "_w", w*10, "_ncov", p, ".RData"))

n_covariates <- dim(data)[2]
outcome <- binary_outcome
data <- cbind(outcome, as.data.frame(data))

############################### Fit using outcome ##############################

prof_regr <-profRegr(yModel="Bernoulli",
                    xModel="Discrete",
                    nSweeps=10000,
                    nClusInit=15,
                    nBurn=2000,
                    data=data,
                    output=paste0("premium/binary-outcome/experiment",
                                  experiment, "_w", w*10, "_ncov", p, "_chain",
                                  chain),
                    covNames = paste0("Variable", seq(1,n_covariates)),
                    seed=12345)

save(prof_regr,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain, "_output_prof_regr.RData"))

dissimObj = PReMiuM::calcDissimilarityMatrix(prof_regr)
dissMat = PReMiuM::vec2mat(dissimObj$disSimMat, nrow = length(outcome))
psm <- 1-dissMat
coph_corr <- copheneticCorrelation(psm)

save(psm, coph_corr, binary_outcome,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain, "_psm.RData"))

############################ Fit excluding outcome #############################
prof_regr <-profRegr(yModel="Bernoulli",
                     xModel="Discrete",
                     nSweeps=10000,
                     nClusInit=15,
                     nBurn=2000,
                     data=data,
                     output=paste0("premium/binary-outcome/experiment",
                                   experiment, "_w", w*10, "_ncov", p, "_chain",
                                   chain, "_exclude_y"),
                     covNames = paste0("Variable", seq(1,n_covariates)),
                     excludeY = TRUE,
                     seed=12345)

save(prof_regr,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain,
                   "_output_prof_regr_exclude_y.RData"))


dissimObj = PReMiuM::calcDissimilarityMatrix(prof_regr)
dissMat = PReMiuM::vec2mat(dissimObj$disSimMat, nrow = length(outcome))
psm <- 1-dissMat
coph_corr <- copheneticCorrelation(psm)

save(psm, coph_corr, binary_outcome,
     file = paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                   "_ncov", p, "_chain", chain, "_psm_exclude_y.RData"))
