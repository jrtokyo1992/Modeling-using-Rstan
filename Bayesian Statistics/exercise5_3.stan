
data {
  int<lower=0> N;
  vector[N] y;
  real<lower = 0> sigma[N];
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu;
  real<lower=0, upper = sqrt(40)> tau;
  vector[N] theta;
}


model {
  for (i in 1:N){
  theta[i] ~normal(mu, tau);
  y[i] ~ normal(theta[i], sigma[i]);
  }
}

