
data {
  int<lower=0> K;
  int y[K]; // must be the integer. y[k] follows a binomial distribution.
  int sample_size[K];
  vector[K] x;
}

transformed data {
  vector[2] mu;
  matrix[2,2] sigma;
  mu[1] =0;
  mu[2] = 10;
  sigma[1,1] = 2^2;
  sigma[1,2] = 0.5*2*10;
  sigma[2,1] = 0.5*2*10;
  sigma[2,2] = 10^2;
}

// y_k ~ binomial(n_k, \theta_k), where logit(theta) = \alpha + \beta * x_k
parameters {
  vector[2] coef;
}

transformed parameters {
  real alpha;
  real beta;
  alpha = coef[1];
  beta = coef[2];
}



model {
   coef ~ multi_normal(mu, sigma);
   for (k in 1:K) {
    y[k] ~binomial(sample_size[k], exp(alpha + beta*x[k])/(1.0+exp(alpha + beta*x[k])));
  }
}

