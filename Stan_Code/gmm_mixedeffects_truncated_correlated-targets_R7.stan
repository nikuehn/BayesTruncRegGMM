/* ****************************************************
  Truncated regression model for multiple target variables.
   **************************************************** */

data {
  int<lower=1> N;     // overall number of records
  int<lower=1> NEQ;   // number of earthquakes
  int<lower=1> NSTAT; // number of stations
  int<lower=1> NP;    // number of periods (target variables)

  vector[N] M;        // magnitude for each record
  vector[N] R;        // distance for each record
  vector[NP] Y[N];    // log psa values

  real Ytrunc;        // truncation threshold

  int<lower=1,upper=NEQ> eq[N];       // earthquake id
  int<lower=1,upper=NSTAT> stat[N];   // station id
}

transformed data {
  vector[NP] mu = rep_vector(0,NP);
  vector[N] M2 = square(8 - M);
  vector[N] lnR = log(R + 6);
  vector[N] MlnR = M .* log(R + 6);
}


parameters {
  vector<lower=0>[NP] phi_ss;    // within-event/within-site standard deviation
  vector<lower=0>[NP] tau;       // between-event standard deviation
  vector<lower=0>[NP] phi_s2s;   // site-to-site standard deviation

  vector[NP] c1;
  vector[NP] c2;
  vector[NP] c3;
  vector[NP] c4;
  vector[NP] c5;
  vector<upper=0>[NP] c6;

  vector[NP] deltaB[NEQ];       // event terms
  vector[NP] deltaS[NSTAT];     // station terms

  cholesky_factor_corr[NP] L_p;     // cholesky factor of correlation matrix for records
  cholesky_factor_corr[NP] L_eq;    // cholesky factor of correlation matrix for event terms
  cholesky_factor_corr[NP] L_stat;  // cholesky factor of correlation matrix for station terms
}

model {
  vector[NP] mu_rec[N];
  matrix[NP,NP] L_Sigma;
  matrix[NP,NP] L_Sigma_eq;
  matrix[NP,NP] L_Sigma_stat;

  // prior distributions for standard deviations
  phi_ss ~ normal(0,1);
  tau ~ normal(0,1);
  phi_s2s ~ normal(0,1);

  // prior distribution for coefficients
  c1 ~ normal(0,5);
  c2 ~ normal(0,5);
  c3 ~ normal(0,5);
  c4 ~ normal(0,5);
  c5 ~ normal(0,5);
  c6 ~ normal(0,0.01);

  // prior for correlation matrices, and calculation of covariance matrices
  L_p ~ lkj_corr_cholesky(1);
  L_Sigma = diag_pre_multiply(phi_ss, L_p);

  L_eq ~ lkj_corr_cholesky(1);
  L_Sigma_eq = diag_pre_multiply(tau, L_eq);

  L_stat ~ lkj_corr_cholesky(1);
  L_Sigma_stat = diag_pre_multiply(phi_s2s, L_stat);

  // correlated prior for event and station terms
  deltaB ~ multi_normal_cholesky(mu,L_Sigma_eq);
  deltaS ~ multi_normal_cholesky(mu,L_Sigma_stat);

  // calculation of median predictions
  for(i in 1:N) {
    mu_rec[i] = c1 + c2 * M[i] +  c3 * M2[i] + c4 * lnR[i] + c5 * MlnR[i] + c6 * R[i] + deltaB[eq[i]] + deltaS[stat[i]];
  }

  // observation likelihood
  target += multi_normal_cholesky_lpdf(Y | mu_rec, L_Sigma) - normal_lccdf(Ytrunc | mu_rec[:,1],phi_ss[1]);
}
