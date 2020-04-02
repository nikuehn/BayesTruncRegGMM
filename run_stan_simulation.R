#devtools::install_github("stan-dev/cmdstanr")

library(cmdstanr)

# set path
set_cmdstan_path(PATH_TO_CMDSTAN)
cmdstan_version()

data <- read.csv('DATA/data_simulated_dataset3.csv')
data_used <- data[1:1000,] # subset of data to make the model run fast

# create new station index ranging from 1 to number of stations
statid <- unique(data_used$STATID)
stat_idx <- rep(0, length(data_used[,1]))
for(i in 1:length(statid)) {
  stat_idx[which(data_used$STATID %in% statid[i])] <- i
} 

# create new event index ranging from 1 to number of stations
eqid <- unique(data_used$EQID)
eq_idx <- rep(0, length(data_used[,1]))
for(i in 1:length(eqid)) {
  eq_idx[which(data_used$EQID %in% eqid[i])] <- i
} 

# ---------------------------------------------------------------------
# Run simple non-truncated regression
file <- file.path("Stan_code", "gmm_mixedeffects_nontruncated_R1.stan")
mod <- cmdstan_model(file)

mod$print() # print Stan code

# create data list
data_stan <- list(
  N = length(data_used[,1]),
  NEQ = max(eq_idx),
  NSTAT = max(eq_idx),
  eq = eq_idx,
  stat = eq_idx,
  M = data_used$M,
  R = data_used$R,
  Y = data_used$Y_1 # regression for first target variable
)

# fit model
fit <- mod$sample(
  data = data_stan, 
  seed = 123, 
  num_chains = 2,
  num_warmup = 200,
  num_samples = 200
)

# print summary
fit$cmdstan_summary()


# ---------------------------------------------------------------------
# Run truncated regession for two target variables
# Select subset based on truncation threshold
trig_level <- log(10./980)
data_used <- data[data$Y_1 > trig_level,]

# create new station index ranging from 1 to number of stations
statid <- unique(data_used$STATID)
stat_idx <- rep(0, length(data_used[,1]))
for(i in 1:length(statid)) {
  stat_idx[which(data_used$STATID %in% statid[i])] <- i
} 

# create new event index ranging from 1 to number of stations
eqid <- unique(data_used$EQID)
eq_idx <- rep(0, length(data_used[,1]))
for(i in 1:length(eqid)) {
  eq_idx[which(data_used$EQID %in% eqid[i])] <- i
} 


file <- file.path("Stan_code", "gmm_mixedeffects_truncated_correlated-targets_R7.stan")
mod <- cmdstan_model(file)

mod$print() # print Stan code

# create data list
y_position <- c(6,7) # position of targe variables in data frame - first one should be PGA (variable that is truncated)
n_targets <- length(y_position)

data_stan <- list(
  N = length(data_used[,1]),
  NEQ = max(eq_idx),
  NSTAT = max(eq_idx),
  NP = n_targets,
  Ytrunc = trig_level,
  eq = eq_idx,
  stat = eq_idx,
  M = data_used$M,
  R = data_used$R,
  Y = data_used[,y_position]
)

# fit model
fit <- mod$sample(
  data = data_stan, 
  seed = 123, 
  num_chains = 2,
  num_cores = 2,
  num_warmup = 200,
  num_samples = 200
)

# print summary
fit$cmdstan_summary()
