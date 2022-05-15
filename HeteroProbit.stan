// This is a stan code estimating the probit model with heterogeneous sigma
functions{
  real MyProbit_lpdf(real y, real xb, real sigma){
    real res;
    // pr (y =1 | xb) = pr (err > -xb)  in which err ~ N(0, sigma^2)
    if (y ==1) {
      res = log( 1-normal_cdf (-xb, 0, sigma) );
    }else{
      res = log( normal_cdf (-xb, 0, sigma) );
    }
    return res;
  }
}


data {
  int<lower=0> N;
  int K_x;
  int K_z;
  int y[N];
  matrix[N, K_x] x;
  matrix[N, K_z] z;
}

parameters {
  vector[K_z] delta;
  vector[K_x] beta;
}

transformed parameters {
  vector[N] sigma;
  for ( i in 1:N){
    sigma[i] = sqrt(exp(z[i]*delta));
  }
}

model {
  for (i in 1:N){
  y[i] ~ MyProbit(x[i]*beta, sigma[i]);
 // y[i] ~ bernoulli(Phi(  x[i]*beta/sigma[i])); you can also use this, which is faster.
  }
}

