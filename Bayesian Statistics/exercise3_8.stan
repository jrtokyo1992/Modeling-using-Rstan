

data {
  int<lower=0> N1;
  vector[N1] y1;
  int<lower=0> N2;
  vector[N2] y2;
}


parameters {
  real<lower =0, upper = 1> u_1; // defined u_1 = alpha/(alpha+ beta)
  real<lower =0> v_1; // defined v_1 = (alpha+ beta)
   real<lower =0, upper = 1> u_2; // defined u_2 = alpha/(alpha+ beta)
  real<lower =0> v_2;  //defined v_2 = (alpha+ beta)
}


transformed parameters {
  real<lower =0> alpha_1; 
  real<lower =0> beta_1; 
  real<lower =0 > alpha_2; 
  real<lower =0> beta_2; 
  alpha_1 = u_1 *v_1;
  beta_1 =  (1-u_1)*v_1;
  alpha_2 = u_2 *v_2;
  beta_2 =  (1-u_2)*v_2;
}

model {
  y1 ~ beta(alpha_1, beta_1); // expectation is u_1
  y2 ~ beta(alpha_2, beta_2);//// expectation is u_2
}

