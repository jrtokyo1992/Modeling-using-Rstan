
data {
  int<lower=0> N;
  int y[N];
  int sample_size[N];
}


parameters {
  real mu;
  real<lower=0> tau;
  real<lower = 0> logit_theta[N]; 
}


model {
  for (i in 1:N){
  logit_theta[i] ~normal(mu, tau);
  y[i] ~ binomial(sample_size[i], exp(logit_theta[i])/(exp(logit_theta[i]+1)));
  }
}

