// censored model 

functions {
  real mycensored_lpdf(real y , real xb, real sigma){
    real res;
    if (y == 0) {
      res = log(1-normal_cdf( xb/sigma , 0,1));
    }else{
      res = normal_lpdf((y-xb)/sigma | 0,1) -log(sigma) ;// log of prob density
    }
    return res;
  }
}


data {
  int<lower=0> N;
  int<lower=0> K;
  vector[N] y;  // when we say vector, we always say column vector
  matrix[N,K] x;
}


parameters {
  vector[K] beta;
  real<lower=0> sigma;
}


model {
  for (i in 1: N){
  y[i] ~ mycensored( x[i]*beta, sigma );
  }
}

