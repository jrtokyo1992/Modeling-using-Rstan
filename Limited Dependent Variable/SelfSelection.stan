functions {
 real MyCondNormal_lpdf(real a1, real a2, real sigma1 , real sigma2, real rho){
    real res;
    //  calcuate pr(err1>a1 | err2 = a2) 
    // err1 and err2 follow joint normal distribution with mean 0, sigma1,sigma2, rho
    // Therefore, err1|err2 = a2 ~ N (sigma1*rho/sigma2 * a2, (1-rho^2)*sigma^2)
    res = log(1-normal_cdf(a1, (sigma1*rho/sigma2)*a2, sqrt((1-rho^2)*sigma1^2 ) )) ;
    return (res);
  }
}


data {
  int<lower = 0> N;
  int<lower = 0> k_1;
  int<lower = 0> k_2;
  vector[N] y; / outcome 
  int D[N]; // whether get treatment or not. D= 1( x_1[i]*beta_1+err1 >0)
  matrix[N,k_1] x_1;
  matrix[N,k_2] x_2;
}


parameters {
  vector[k_1] beta_1; // coefficient in the entering decision
  vector[k_2] beta_2; // coefficient of main equation
  real rho;
  real sigma2;
}


model {
   for (i in 1:N){
     if ( D[i] == 1) {
      // pr( D =1 , x2*beta_2 + err2 = y) = pr( x1*beta_1 + err1>0 | x2*beta_2 + err2 = y) pr(x2*beta_2 + err2 = y)
     target += MyCondNormal_lpdf(- x_1[i]*beta_1 | y[i]-x_2[i]*beta_2 , 1, sigma2,rho)+normal_lpdf ((y[i]-x_2[i]*beta_2)| 0, sigma2);
      }else{
     target += MyCondNormal_lpdf(x_1[i]*beta_1 | y[i]-x_2[i]*beta_2 ,1, sigma2,-rho)+normal_lpdf ((y[i]-x_2[i]*beta_2)| 0, sigma2);
      }
    }
}

