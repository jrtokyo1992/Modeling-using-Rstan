// For local level model: stochastic
data {
  int<lower=1> n;
  int<lower=1> n_new;
  int<lower=1> k_x; 
  vector[n] y;
  matrix[n, k_x] x;
}
parameters {
  vector[n] mu;
  vector[k_x] beta; 
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}

transformed parameters {
  vector[n] yhat;
  yhat = mu + x* beta;
}

model {
  mu[2:n] ~ normal(mu[1:n-1], sigma_level);
  y ~ normal(yhat, sigma_irreg);
}

generated quantities{
  vector[n+n_new] pred;
  vector[n] log_lik; // also calculate the likelihood: this is for calculating WAIC.
  // be sure to write down the correct log likelihood function
  log_lik[1] = normal_lpdf(y[1]|yhat[1], sigma_irreg);
  pred[1:n] = mu[1:n];
  for (i in 2:n){
   // pred[i] = normal_rng(mu[i], sigma_irreg);
    log_lik[i] = normal_lpdf(y[i]|yhat[i], sigma_irreg) + normal_lpdf(mu[i]|mu[i-1],sigma_level);
  }
  for (i in n+1: (n+n_new)){
    pred[i] = normal_rng(pred[i-1], sigma_level);
  }
}

