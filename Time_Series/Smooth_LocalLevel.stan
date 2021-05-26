// For smooth local level model 
data {
  int<lower=1> n;
  int<lower=1> n_new;
  int<lower=1> k_x; 
  vector[n] y;
  matrix[n, k_x] x;
  
}
parameters {
  real alpha;
  vector[n] mu;
  vector[k_x] beta; 
  real<lower=0> sigma_irreg;
  real<lower=0> sigma_drift;
}

transformed parameters{
  vector[n] yhat;
  yhat = mu + x* beta;
}

model {
//  mu[1] = x[1,]*beta;
//  mu[2] = u[1] + x[2,]*beta; 
 // mu[1] ~ normal(1,1);
 // mu[2] ~ normal(0,1);
  //beta ~ normal (0.5, 0.5);
  
//for(t in 3:n){
   mu[3:n] ~ normal(2*mu[2:n-1]-mu[1:n-2], sigma_drift);
   //mu[t] ~ normal(2*mu[t-1]-mu[t-2]+ x[t-2,]*beta - x[t,]*beta, sigma_drift);
 //  mu[t] ~ normal(2*mu[t-1]-mu[t-2], sigma_drift);
//  }
  y ~ normal(yhat, sigma_irreg);
}

generated quantities{
  vector[n] pred;
  vector[n] log_lik; // also calculate the likelihood: this is for calculating WAIC.
  // be sure to write down the correct log likelihood function
  log_lik[1] = normal_lpdf(y[1]|mu[1], sigma_irreg);
  log_lik[2] = normal_lpdf(y[2]|mu[2], sigma_irreg);
  pred = yhat;
  for (i in 3:n){
   // pred[i] = normal_rng(mu[i], sigma_irreg);
    log_lik[i] = normal_lpdf(y[i]|yhat[i], sigma_irreg) + 
      normal_lpdf(mu[i]|2*mu[i-1]-mu[i-2],sigma_drift);
  }
 // for (i in n+1: (n+n_new)){
 //   pred[i] = normal_rng(pred[i-1], sigma_level);
 // }
}

