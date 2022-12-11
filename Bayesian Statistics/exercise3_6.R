
library(dplyr)
library(rstan)
library(ggplot2)

## this example seems to show that under some conditions, the model that considers measurement error can lead to less variance in the posterior mean estimation.

warmup = 2000
iter = 4000
chains = 4
thin = 4

## The statements in the transformed data block are designed to be executed once and have a deterministic result. Therefore, log probability is not accumulated and sampling statements may not be used.
## in other words, you can only define some 'deterministic' things in the transofmred data block. you cannot define some latent random variables here. 
## rstan does not support discrete latent variables. 
## therefore, you may want to marginalize over you discrete latent variables if any. (which means your final loglikelihood is log(\sum{prob})) 
## rstan will take care of this log_sum using MCMC or EM. 
## https://mc-stan.org/docs/stan-users-guide/change-point.html

model_exercise3_6 = stan(file = "exercise3_6.stan",
                                 data = list(
                                   y = c(53, 57, 66, 67, 72), 
                                   K = 5
                                 ),
                                 seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample_noerror = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             mu = model_exercise3_5_noerror@sim[["samples"]][[k]][["mu"]], 
                             log_sigma = model_exercise3_5_noerror@sim[["samples"]][[k]][["log_sigma"]],
                             pred_y = model_exercise3_5_noerror@sim[["samples"]][[k]][["z"]]
                             
  )
  
  params_sample_noerror = rbind(params_sample_noerror, current_chain)
  
}

params_sample_noerror %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = mu)) + geom_density()

var(params_sample_noerror$mu)

params_sample_noerror %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = pred_y)) + geom_density()



#####

model_exercise3_5_witherror = stan(file = "exercise3_5_witherror.stan",
                                   data = list(
                                     y = c(10,10,12,11,9), 
                                     N = 5
                                   ),
                                   seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample_witherror = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             mu = model_exercise3_5_witherror@sim[["samples"]][[k]][["mu"]], 
                             sigma = model_exercise3_5_witherror@sim[["samples"]][[k]][["log_sigma"]],
                             pred_y = model_exercise3_5_witherror@sim[["samples"]][[k]][["z"]]
                             
  )
  
  params_sample_witherror = rbind(params_sample_witherror, current_chain)
  
}

params_sample_witherror %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = mu)) + geom_density()

var(params_sample_witherror$mu)

params_sample_witherror %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = pred_y)) + geom_density()


