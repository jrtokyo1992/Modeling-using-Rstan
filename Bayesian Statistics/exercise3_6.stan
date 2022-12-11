// measurement error model
data {
  int<lower=0> K;
  int<lower=0> y[K];
}

transformed data {
  int<lower = 72> N;
}

// The statements in the transformed data block are designed to be executed once and have a deterministic result. Therefore, log probability is not accumulated and sampling statements may not be used.
// in other words, you can only define some 'deterministic' things in the transofmred data block. you cannot define some latent random variables here. 
parameters {
  real<lower = 0> mu;
  real<lower =0, upper = 1> theta;
}



model {
  N~poisson(mu);
  y~binomial(N, theta);
}

//