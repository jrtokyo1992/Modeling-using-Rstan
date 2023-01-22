library(dplyr)
library(rstan)
library(mvtnorm)
library(ggplot2)


mu_x= rnorm(100) # mu = 0, tau = 1
mu_y = mu_x * 2 +1
sigma = matrix(c(1,0.5,0.5,1), nrow=2, ncol=2)
d = matrix(0, nrow = length(mu_x), ncol = 2)
for (i in 1: length(mu_x)){
d[i,] = rmvnorm(1, mean = c(mu_x[i],mu_y[i]), sigma = sigma)
}

warmup = 4000
iter = 8000
chains = 4
thin = 4

model_straighline_fitting = stan(file = "straightline_fitting.stan",
                                  data = list(d = d, N = length(mu_x)),
                                  seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)


params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             mu = model_straighline_fitting@sim[["samples"]][[k]][["mu"]], 
                             tau = model_straighline_fitting@sim[["samples"]][[k]][["tau"]],
                             a = model_straighline_fitting@sim[["samples"]][[k]][["a"]],
                             b = model_straighline_fitting@sim[["samples"]][[k]][["b"]],
                             corr_var = model_straighline_fitting@sim[["samples"]][[k]][["corr_var"]]
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}

params_sample%>% ggplot(aes(x = a)) +geom_density()

params_sample %>% filter(time>warmup/thin)%>%
  ggplot(., aes(x = time, y = a)) + geom_line() + facet_wrap(~chain, nrow = 2)  

params_sample%>% ggplot(aes(x = b)) +geom_density()
params_sample%>% ggplot(aes(x = mu)) +geom_density()
params_sample%>% ggplot(aes(x = tau)) +geom_density()
params_sample%>% ggplot(aes(x = corr_var)) +geom_density()

mean(params_sample$a)
median(params_sample$a)
mean(params_sample$b)
median(params_sample$b)


### now use real data. 

df = data.frame(
mass= c(31.2,24.0,19.8,18.2,9.6,6.5,3.2),
surface = c(10750,8805,7500,7662,5286,3724,2423),
metabolic = c(1113,982,908,842,626,430,281))


warmup = 4000
iter = 8000
chains = 4
thin = 4

d = df%>%mutate(log_mass = log(mass), log_metabolic= log(metabolic)) %>% select (log_mass, log_metabolic) %>%
  as.matrix(.)
model_straighline_fitting_real_data = stan(file = "straightline_fitting.stan",
                                 data = list(d = d, N = nrow(d)),
                                 seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)
  
  
params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             mu = model_straighline_fitting_real_data@sim[["samples"]][[k]][["mu"]], 
                             tau = model_straighline_fitting_real_data@sim[["samples"]][[k]][["tau"]],
                             a = model_straighline_fitting_real_data@sim[["samples"]][[k]][["a"]],
                             b = model_straighline_fitting_real_data@sim[["samples"]][[k]][["b"]],
                             sigma = model_straighline_fitting_real_data@sim[["samples"]][[k]][["sigma"]]
                           #  corr_var = model_straighline_fitting_real_data@sim[["samples"]][[k]][["corr_var"]]
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}
  
  
params_sample%>% ggplot(aes(x = b)) +geom_density()
