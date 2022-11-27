data {
  int y[3];
  //real alpha[3];
}

transformed data {
  int N = sum(y);
  vector<lower=0>[3] alpha;
  for (k in 1:3) {
    alpha[k] = 1.0/3;
  }
}


parameters {
  simplex[3] theta;
//  simplex[4] p2; (see the second method in the model part)
}

model {
  theta ~ dirichlet(alpha);
  y ~ multinomial(theta);
  // second method: or you can decompose the data generation process into several steps of binomial distribution.
  // this applies the properties of multinomial distribution.
 // y[1] ~ binomial(N, p2[1]);
 // y[2] ~ binomial(N - y[1], p2[2] / (1 - p2[1]));
 // y[3] ~ binomial(N - y[1] - y[2], p2[3] / (1 - p2[1] - p2[2]));
}

generated quantities {
  real lp1 = multinomial_lpmf(y |theta);
  // the log-liklihood in the second method is as follows:
//  real lp2 = binomial_lpmf(y[1] | N, p1[1]) +
//  binomial_lpmf(y[2] | N - y[1], p1[2] / (1 - p1[1])) +
//  binomial_lpmf(y[3] | N - y[1] - y[2], p1[3] / (1 - p1[1] - p1[2]));
//  real diff = lp1 - lp2;
}

