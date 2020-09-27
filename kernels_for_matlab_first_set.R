rm(list=ls())

library(klic)
library(R.matlab)

n_experiments <- 100
chain <- 1
n_cov <- 10

### Classical mixture ###
for(experiment in 1:n_experiments){
  # for(n_cov in c(10, 12, 15, 20)){
    for(w in c(0.2, 0.4, 0.6, 0.8)){
      # for(var_sel in c("", "_var_sel")){
        load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
                    "_ncov", n_cov, "_chain", chain, "_psm_exclude_y.RData"))
        psm <- spectrumShift(psm)
        writeMat(paste0("kernels-matlab/binary-outcome/experiment", experiment,
                        "_w", w*10, "_ncov", n_cov, "_chain", chain,
                        "_psm_exclude_y.mat"),
                 psm = psm, binary_outcome = binary_outcome)
      # }
    }
  # }
}
# 
# ### Permuted data ###
# for(experiment in 1:n_experiments){
#   for(n_cov in c(10)){
#     for(w in 0.8){
#       for(var_sel in c("", "_var_sel")){
#         load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
#                     "_ncov", n_cov, "_chain", chain,
#                     "_psm_exclude_y_permuted.RData"))
#         psm <- spectrumShift(psm)
#         writeMat(
#                paste0("kernels-matlab/binary-outcome/experiment", experiment,
#                       "_w", w*10, "_ncov", n_cov, "_chain", chain,
#                       "_psm_exclude_y_permuted.mat"),
#                psm = psm, binary_outcome = binary_outcome)
#       }
#     }
#   }
# }
# 
# ### Variable selection ###
# for(experiment in 1:n_experiments){
#   for(n_cov in c(12, 15, 20)){
#     for(w in c(0.2, 0.4, 0.6, 0.8)){
#       for(var_sel in c("", "_var_sel")){
#         load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
#                     "_ncov", n_cov, "_chain", chain,
#                     "_psm_exclude_y_var_sel.RData"))
#         psm <- spectrumShift(psm)
#         writeMat(
#           paste0("kernels-matlab/binary-outcome/experiment", experiment, "_w",
#                  w*10, "_ncov", n_cov, "_chain", chain,
#                  "_psm_exclude_y_var_sel.mat"),
#           psm = psm, binary_outcome = binary_outcome)
#       }
#     }
#   }
# }
# 
# ### Profile regression ###
# for(experiment in 1:n_experiments){
#   for(n_cov in c(10)){
#     for(w in c(0.2, 0.4, 0.6, 0.8)){
#       for(var_sel in c("", "_var_sel")){
#         load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
#                     "_ncov", n_cov, "_chain", chain, "_psm.RData"))
#         psm <- spectrumShift(psm)
#         writeMat(paste0("kernels-matlab/binary-outcome/experiment", experiment,
#                         "_w", w*10, "_ncov", n_cov, "_chain", chain,
#                         "_psm.mat"),
#                  psm = psm, binary_outcome = binary_outcome)
#       }
#     }
#   }
# }
# 
# ### Profile regression for permuted data ###
# for(experiment in 1:n_experiments){
#   for(n_cov in 10){
#     for(w in 0.8){
#       for(var_sel in c("", "_var_sel")){
#         load(paste0("premium/binary-outcome/experiment", experiment, "_w", w*10,
#                     "_ncov", n_cov, "_chain", chain, "_psm_permuted.RData"))
#         psm <- spectrumShift(psm)
#         writeMat(paste0("kernels-matlab/binary-outcome/experiment", experiment,
#                         "_w", w*10, "_ncov", n_cov, "_chain", chain,
#                         "_psm_permuted.mat"),
#                  psm = psm, binary_outcome = binary_outcome)
#       }
#     }
#   }
# }
