################################################################################
############################## Define permutation ##############################
################################################################################

set.seed(1)
observations <- 1:300
permuted_observations <- sample(observations)
sum(1-sort(unique(permuted_observations))==observations)
save(permuted_observations, file = "data/permutation.RData")
