
data {
  int<lower=0> K;
  int y[K]; // must be the integer. y[k] follows a binomial distribution.
  int sample_size[K];
  vector[K] x;
}

// y_k ~ binomial(n_k, \theta_k), where logit(theta) = \alpha + \beta * x_k
parameters {
  real alpha;
  real<lower = 0> beta;
}



model {
   for (k in 1:K) {
    y[k] ~binomial(sample_size[k], exp(alpha + beta*x[k])/(1.0+exp(alpha + beta*x[k])));
  }
}

