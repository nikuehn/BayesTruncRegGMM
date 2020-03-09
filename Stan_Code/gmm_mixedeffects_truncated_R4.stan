/* ****************************************************
  Truncated regression model for one target variable.
  Truncation threshold is exactly known.
   **************************************************** */

data {
  int<lower=1> N;     // overall number of records
  int<lower=1> NEQ;   // number of earthquakes
  int<lower=1> NSTAT; // number of stations

  vector[N] M;        // magnitude for each record
  vector[N] R;        // distance for each record
  vector[N] Y;        // log pga for each record

  real Ytrunc;        // truncation threshold

  int<lower=1,upper=NEQ> eq[N];       // earthquake id
  int<lower=1,upper=NSTAT> stat[N];   // station id
}

transformed data {
  // calculate linear predictors

  vector[N] M2 = square(8 - M);
  vector[N] lnR = log(R + 6);
  vector[N] MlnR = M .* log(R + 6);
}


parameters {
  real<lower=0> phi_ss;    // within-event/wthin-site standard deviation
  real<lower=0> tau;       // between-event standard deviation
  real<lower=0> phi_s2s;   // site-tos-te standard deviation

  real c1;
  real c2;
  real c3;
  real c4;
  real c5;
  real<upper=0> c6;

  vector[NEQ] deltaB;      // event terms
  vector[NSTAT] deltaS;    // station terms
}

model {
  vector[N] mu_rec;

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

  // prior distribution for  event and station terms
  deltaB ~ normal(0,tau);
  deltaS ~ normal(0,phi_s2s);

  // median predictions
  mu_rec = c1 + c2 * M + c3 * M2 + c4 * lnR + c5 * MlnR + c6 * R + deltaB[eq] + deltaS[stat];

  // observation likelihood
  target += normal_lpdf(Y | mu_rec, phi_ss) - normal_lccdf(Ytrunc | mu_rec, phi_ss);
}
