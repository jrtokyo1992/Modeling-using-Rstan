// For local trend model 
data {
  int<lower=1> n;
  int<lower=1> n_new;
  int<lower=1> k_x; 
  vector[n] y;
  matrix[n, k_x] x;
  
}
parameters {
  vector[n] mu;
  vector[n] v;
  vector[k_x] beta; 
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
  real<lower =0> sigma_drift;
}

transformed parameters {
  vector[n] yhat;
  yhat = mu + x*beta ;
}

model {
    sigma_level ~ normal(2,2);
    sigma_drift ~ normal(2,2);
    sigma_irreg ~ normal(2,2);
    mu[1] ~ normal(x[1,]*beta , sigma_level);
 // for(t in 2:n){
    v[2:n] ~ normal (v[1:n-1], sigma_drift);
    mu[2:n] ~ normal(mu[1:n-1]  + v[1:n-1], sigma_level);
 // }
  y ~ normal(yhat, sigma_irreg);
}

generated quantities{
  vector[n+n_new] pred;
  vector[n] log_lik; // also calculate the likelihood: this is for calculating WAIC.
  // be sure to write down the correct log likelihood function
  log_lik[1] = normal_lpdf(y[1]|yhat[1], sigma_irreg);
  pred[1:n] = yhat;
  for (i in 2:n){
   // pred[i] = normal_rng(mu[i], sigma_irreg);
    log_lik[i] = normal_lpdf(y[i]|yhat[i], sigma_irreg) + normal_lpdf(mu[i]|mu[i-1] + v[i-1],sigma_level)+
      normal_lpdf(v[i]| v[i-1], sigma_drift);
  }
  for (i in n+1: (n+n_new)){
    pred[i] = normal_rng(pred[i-1], sigma_level);
  }
}

