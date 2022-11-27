

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N1;
  int<lower=0> N2;
  real avg_y1;
  real avg_y2;
  real<lower =0> se1;
  real<lower = 0> se2;
}


parameters {
  real mu1;
  real mu2;
  real log_sigma1;
  real log_sigma2;
}


model {
  target += -((N1-1)*se1^2 + N1*(avg_y1-mu1)^2)*0.5/(exp(log_sigma1)^2) - (0.5*N1)*log(2*pi()) - N1*log_sigma1;
  target += -((N2-1)*se2^2 + N2*(avg_y2-mu2)^2)*0.5/(exp(log_sigma2)^2) - (0.5*N2)*log(2*pi()) - N2*log_sigma2;
  
}

