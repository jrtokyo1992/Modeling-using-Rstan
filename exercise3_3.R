library(dplyr)
library(rstan)
library(ggplot2)

avg_y1 = 1.013
avg_y2 = 1.173
N1 = 32
N2 = 36
se1 =  0.24
se2 = 0.2


## use Bayesian estimation.
warmup = 2000
iter = 4000
chains = 4
thin = 4

model_exercise3_3 = stan(file = "exercise3_3.stan",
                      data = list(avg_y1 = avg_y1,
                                 avg_y2 = avg_y2,
                                  N1 = N1,
                                  N2 = N2,
                                  se1 =  se1,
                                 se2 = se2
                               ),
                      seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             mu1 = model_exercise3_3@sim[["samples"]][[k]][["mu1"]], 
                             mu2 = model_exercise3_3@sim[["samples"]][[k]][["mu2"]], 
                             log_sigma1 = model_exercise3_3@sim[["samples"]][[k]][["log_sigma1"]], 
                             log_sigma2 = model_exercise3_3@sim[["samples"]][[k]][["log_sigma2"]]
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}

## check whether covergence holds:
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = mu1)) + geom_line() + facet_wrap(~chain, nrow = 2)  
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = mu2)) + geom_line() + facet_wrap(~chain, nrow = 2)  
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = log_sigma1)) + geom_line() + facet_wrap(~chain, nrow = 2)  
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = log_sigma2)) + geom_line() + facet_wrap(~chain, nrow = 2)  
## evaluate the uncertainty of the MCMC sample.

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = mu1)) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = exp(log_sigma1))) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = mu2)) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = exp(log_sigma2))) + geom_density()


params_sample %>% filter (time >= warmup/thin) %>% 
  mutate(mu_diff = mu2- mu1) %>%
  ggplot(aes(x = mu_diff )) + geom_density()


## or use MLE
mod = stan_model ('exercise3_3.stan')
model_res = NULL
model_value = -Inf
i = 1
while (i<30){
  temp = optimizing (mod, data = list(avg_y1 = avg_y1,
                                             avg_y2 = avg_y2,
                                             N1 = N1,
                                             N2 = N2,
                                             se1 =  se1,
                                             se2 = se2
  ),
                     #  verbose = TRUE,
                     hessian = TRUE, as_vector = FALSE)
  if (temp$value>model_value){
    model_res = temp
    model_value = temp$value
  }
  i = i+1
}




