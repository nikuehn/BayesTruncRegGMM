/* ****************************************************
  Truncated regression model for two target variables.
  he first target variable is assumed to be PGA.
  The coefficients, parameters, event and station terms are read in,
    and median predictions fo PGA are calculated.

  The parameters for the other target variable are estimated.

  No correlation is assumed for event terms and station terms.
  For the record leve, the correlation is estimated.
   **************************************************** */

data {
  int<lower=1> N;     // overall number of records
  int<lower=1> NEQ;   // number of earthquakes
  int<lower=1> NSTAT; // number of stations

  vector[N] M;        // magnitude for each record
  vector[N] R;        // distance for each record
  vector[2] Y[N
  
  int<lower=1,upper=NEQ> eq[N];       // earthquake id
  int<lower=1,upper=NSTAT> stat[N];     // station id

  // parameters of PGA model
  real c1_pga;
  real c2_pga;
  real c3_pga;
  real c4_pga;
  real c5_pga;
  real c6_pga;

  real<lower=0> phi_ss_pga;
  real<lower=0> tau_pga;
  real<lower=0> phi_s2s_pga;

  vector[NEQ] deltaB_pga;
  vector[NSTAT] deltaS_pga;
}

transformed data {
  vector[2] mu = rep_vector(0,2);
  vector[N] M2 = square(8 - M);
  vector[N] lnR = log(R + 6);
  vector[N] MlnR = M .* log(R + 6);

  vector[N] mu_rec_pga;

  mu_rec_pga = c1_pga + c2_pga * M + c3_pga * M2 + c4_pga * lnR + c5_pga * MlnR + c6_pga * R + deltaB_pga[eq] + deltaS_pga[stat];
}


parameters {
  real<lower=0> phi_ss;
  real<lower=0> tau;
  real<lower=0> phi_s2s;

  real c1;
  real c2;
  real c3;
  real c4;
  real c5;
  real<upper=0> c6;

  vector[NEQ] deltaB;
  vector[NSTAT] deltaS;

  cholesky_factor_corr[2] L_p;
}

model {
  vector[2] mu_rec[N];
  matrix[2,2] L_Sigma;
  vector[2] sigma;

  phi_ss ~ normal(0,1);
  tau ~ normal(0,1);
  phi_s2s ~ normal(0,1);

  c1 ~ normal(0,5);
  c2 ~ normal(0,5);
  c3 ~ normal(0,5);
  c4 ~ normal(0,5);
  c5 ~ normal(0,5);
  c6 ~ normal(0,0.01);

  sigma[1] = phi_ss_pga;
  sigma[2] = phi_ss;

  L_p ~ lkj_corr_cholesky(1);
  L_Sigma = diag_pre_multiply(sigma, L_p);


  deltaB ~ normal(0,tau);
  deltaS ~ normal(0,phi_s2s);

  for(i in 1:N) {
    mu_rec[i,2] = c1 + c2 * M[i] + c3 * M2[i] + c4 * lnR[i] + c5 * MlnR[i] + c6 * R[i] + deltaB[eq[i]] + deltaS[stat[i]];
    mu_rec[i,1] = mu_rec_pga[i];
  }

  target += multi_normal_cholesky_lpdf(Y | mu_rec, L_Sigma) - normal_lccdf(Ytrunc | mu_rec[:,1],phi_ss_pga);
}
