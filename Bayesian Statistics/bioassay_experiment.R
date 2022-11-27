library(dplyr)
library(rstan)
library(ggplot2)

x = c(-0.86 ,- 0.3, -0.05, 0.73)
sample_size = c(5,5,5,5)
y = c(0,1,3,5)



warmup = 2000
iter = 4000
chains = 4
thin = 4

model_bioassay = stan(file = "bioassay_experiment.stan",
             data = list(y = y, K = 4,x = x, sample_size = sample_size),
             seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

# for final results, in each chain, the size is iter/thin
## check the convergence of the sampling 

params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             alpha = model_bioassay@sim[["samples"]][[k]][["alpha"]], 
                             beta = model_bioassay@sim[["samples"]][[k]][["beta"]]
                              )
  
  params_sample = rbind(params_sample, current_chain)
  
}

## check whether covergence holds:
params_sample %>% filter(time>warmup/thin)%>%
ggplot(., aes(x = time, y = alpha)) + geom_line() + facet_wrap(~chain, nrow = 2)  
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = beta)) + geom_line() + facet_wrap(~chain, nrow = 2)  
## evaluate the uncertainty of the MCMC sample.

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = beta)) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = alpha)) + geom_density()


##

