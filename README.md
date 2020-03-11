# BayesTruncRegGMM

This reposiory contains Stan code and simulated data sets fom the paper ``A Bayesian Model for Truncated Regression for the Estimation of Empirical Ground-Motion Models'' by Kuehn et al., submitted to BEE.

There are four different Stan models:

* non-truncated regression for one target variable
* truncated regression for one taget variable
* truncated regression for multiple target variables, with truncation on the first target variable.
* truncated regression for multiple target variables, with truncation on the first target variable, and the predictions of the first target variable precalculated.

The Stan models can easily be modified to use different functional forms. For information on Stan, see https://mc-stan.org/.

The DATA folder contains the three simulated data sets, as described in Section 3 of the paper. These are the full data sets, but one can genrate subsets based on truncation by selection only rwos with $Y_1 > -6$, or based on R_MAX by selectiin only rows with $R < R_MAX$.
