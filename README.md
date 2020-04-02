# BayesTruncRegGMM

This reposiory contains Stan code and simulated data sets fom the paper ``A Bayesian Model for Truncated Regression for the Estimation of Empirical Ground-Motion Models'' by Kuehn et al., submitted to BEE.

There are four different Stan models:

* non-truncated regression for one target variable
* truncated regression for one taget variable
* truncated regression for multiple target variables, with truncation on the first target variable.
* truncated regression for multiple target variables, with truncation on the first target variable, and the predictions of the first target variable precalculated.

The Stan models can easily be modified to use different functional forms. For information on Stan, see https://mc-stan.org/.

The DATA folder contains the three simulated data sets, as described in Section 3 of the paper. These are the full data sets, but one can genrate subsets based on truncation by selection only rwos with $Y_1 > -6$, or based on R_MAX by selecting only rows with $R < R_MAX$.

The file `run_stan_simulation.R` shows how to load a data set and perform a simple regression using cmdstanR (https://mc-stan.org/cmdstanr/index.html). For a real application, the sampling parameters should be set to realistic values, and possibly initial values should be specified.

The folder DATA_IRAN contains the Stan input data file and files for initial values to run the truncated regression for the Iranian data set.
The script `data_iran_pgat02_rotd50.Rdata` contains a simple script to run the regression using cmdstanR.
