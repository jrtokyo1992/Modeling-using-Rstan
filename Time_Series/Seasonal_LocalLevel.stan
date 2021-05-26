// For local level model with seasonal effect 
data {
  int<lower=1> n;
  int<lower=1> n_new;
  int<lower=1> k_x; 
  int<lower=1> k_s;
  vector[n] y;
  matrix[n, k_x] x;
}
parameters {

  vector[n] mu;
  vector[n] s ; // season
  
  vector[k_x] beta; 
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
  real<lower=0> sigma_season;
}

transformed parameters {
 vector[n]  yhat;
 yhat = mu + x*beta + s;
}


model {
  for (t in k_s: n){
    s[t] ~ normal(-sum(s[t-k_s+1:t-1]), sigma_season) ;// this is for the stochastic seasonal trend
    // s[t] = - sum(s[t-k_s+1:t-1]) // this is for the determined seasonal compoent
  }
 // for(t in 2:n){
  //  mu[t] ~ normal(mu[t-1]+ x[t,]*beta + s[t-1], sigma_level);
    mu[2:n] ~ normal ( mu[1:n-1],sigma_level);
 // }
  y ~ normal(yhat, sigma_irreg);
}

generated quantities{
  vector[n+n_new] pred;
  vector[n] log_lik; // also calculate the likelihood: this is for calculating WAIC.
  // be sure to write down the correct log likelihood function
  log_lik[1] = normal_lpdf(y[1]|mu[1], sigma_irreg);
  pred[1:n] = yhat;
  for (i in 2:n){
   // pred[i] = normal_rng(mu[i], sigma_irreg);
    log_lik[i] = normal_lpdf(y[i]|yhat[i], sigma_irreg) + normal_lpdf(mu[i]|mu[i-1],sigma_level)+
      normal_lpdf(s[i]| -sum(s[i-k_s+1:i-1]), sigma_season);
  }
  for (i in n+1: (n+n_new)){
    pred[i] = normal_rng(pred[i-1], sigma_level);
  }
}

