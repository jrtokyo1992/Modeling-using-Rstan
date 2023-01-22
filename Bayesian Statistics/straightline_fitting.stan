//
// straight line fitting
// the exercise of 14_12

data {
  int<lower=0> N;
  matrix[N,2] d;
}


parameters {
  real mu;
  real<lower=0> tau;
  real a;
  real b; 
  vector[N] mu_x;
  real<lower=0> sigma;
 // real<lower=0> sigma_x;
 // real<lower=0> sigma_y;
}

transformed parameters {
  matrix[N,2] meanvalue;
  matrix[2,2] covar;
  covar[1,1] = sigma^2;
  covar[2,2] = sigma^2;
  covar[1,2] = 0;
  covar[2,1] = 0;
  for (i in 1:N){
    meanvalue[i,1] = mu_x[i];
    meanvalue[i,2] = b*mu_x[i]+a;
  }
}


model {
  for (i in 1:N){
    mu_x[i] ~ normal(mu, tau);
    d[i,] ~ multi_normal(meanvalue[i,], covar);
  }
  
}

