#devtools::install_github("stan-dev/cmdstanr")

library(cmdstanr)
setwd('/Users/nico/GROUNDMOTION/PROJECTS/GMM_TRUNC/STAN5_github/')

# set path
set_cmdstan_path(PATH_TO_CMDSTAN)
cmdstan_version()

# ---------------------------------------------------------------------
# Run non-truncated regression
file <- file.path("Stan_code", "gmm_iran_nontruncated_correlated-targets.stan")
mod <- cmdstan_model(file)

mod$print() # print Stan code

# fit model
fit <- mod$sample(
  data = 'DATA_IRAN/data_iran_pgat02_rotd50.Rdata', 
  seed = 123, 
  num_chains = 2,
  num_cores = 2,
  num_warmup = 200,
  num_samples = 200,
  max_depth = 12
)

# print summary
fit$cmdstan_summary()


# ---------------------------------------------------------------------
# Run truncated regression
file <- file.path("Stan_code", "gmm_iran_truncated_correlated-targets.stan")
mod <- cmdstan_model(file)

mod$print() # print Stan code

# fit model
fit <- mod$sample(
  data = 'DATA_IRAN/data_iran_pgat02_rotd50.Rdata', 
  seed = 123, 
  num_chains = 2,
  num_cores = 2,
  num_warmup = 200,
  num_samples = 200,
  max_depth = 12,
  init = c('DATA_IRAN/init_gmm_iran_data_iran_pga_rotd50_1.Rdata',
           'DATA_IRAN/init_gmm_iran_data_iran_pga_rotd50_2.Rdata')
)

# print summary
fit2$cmdstan_summary()
