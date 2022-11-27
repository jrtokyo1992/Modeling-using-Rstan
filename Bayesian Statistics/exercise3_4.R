library(dplyr)
library(rstan)
library(ggplot2)


n1 = 674
y1 = 39
n2 = 680
y2 = 22


## use Bayesian estimation.
warmup = 2000
iter = 4000
chains = 4
thin = 4

model_exercise3_4 = stan(file = "exercise3_4.stan",
                         data = list(
                                     n1 = n1,
                                     n2 = n2,
                                     y1 =  y1,
                                     y2 = y2
                         ),
                         seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             p1 = model_exercise3_4@sim[["samples"]][[k]][["p1"]], 
                             p2 = model_exercise3_4@sim[["samples"]][[k]][["p2"]]
                           
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}

## check whether covergence holds:
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = p1)) + geom_line() + facet_wrap(~chain, nrow = 2)  
params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = p2)) + geom_line() + facet_wrap(~chain, nrow = 2)  

## evaluate the uncertainty of the MCMC sample.

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = p1)) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = p2)) + geom_density()

params_sample %>% filter (time >= warmup/thin) %>% 
  mutate (odds_ratio = (p2/(1-p2))/(p1/(1-p1))) %>%
  ggplot(aes(x = odds_ratio)) + geom_density()







