
// measurement error model
data {
  int<lower=0> N;
  int y[N];
}


parameters {
  real mu;
  real log_sigma;
}

model {
  for (i in 1:N) {
    // pr(y = k) = \int_{k-0.5}^{k+0.5} pr(s)ds
  target += log(normal_cdf(y[i]+0.5, mu, exp(log_sigma)) - normal_cdf(y[i]-0.5, mu, exp(log_sigma)));
  }
}


generated quantities {
  real z;
  // use current estimate of theta to generate new sample
  z = normal_rng(mu, exp(log_sigma));
  
  // estimate theta_rep from new sample
}


