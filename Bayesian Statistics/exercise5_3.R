library(dplyr)
library(rstan)
library(ggplot2)


y = c(28,8,-3,7,-1,1,18,12)
sigma = c(15,10,16,11,9,11,10,18)


warmup = 2000
iter = 4000
chains = 4
thin = 4


model_exercise5_3 = stan(file = "exercise5_3.stan",
                      data = list(N = length(y),y = y, sigma = sigma),
                      seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

# for final results, in each chain, the size is iter/thin
## check the convergence of the sampling 

params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                            ## mu = model_exercise5_3@sim[["samples"]][[k]][["mu"]], 
                             ##tau = model_exercise5_3@sim[["samples"]][[k]][["tau"]],
                             theta_1 = model_exercise5_3@sim[["samples"]][[k]][["theta[1]"]],
                             theta_2 = model_exercise5_3@sim[["samples"]][[k]][["theta[2]"]],
                             theta_3 = model_exercise5_3@sim[["samples"]][[k]][["theta[3]"]],
                             theta_4 = model_exercise5_3@sim[["samples"]][[k]][["theta[4]"]],
                             theta_5 = model_exercise5_3@sim[["samples"]][[k]][["theta[5]"]],
                             theta_6 = model_exercise5_3@sim[["samples"]][[k]][["theta[6]"]],
                             theta_7 = model_exercise5_3@sim[["samples"]][[k]][["theta[7]"]],
                             theta_8 = model_exercise5_3@sim[["samples"]][[k]][["theta[8]"]],
                             model_type = 'hierarchical_model'
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}

params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = theta_1)) + geom_density()
params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = theta_2)) + geom_density()

## for example, 
params_sample %>% summarize (sum(theta_1>theta_2)/n())
params_sample %>% summarize (sum(theta_1>theta_3)/n())
params_sample %>% summarize (sum(theta_1>theta_4)/n())
params_sample %>% summarize (sum(theta_1>theta_5)/n())


model_exercise5_3_separate = stan(file = "exercise5_3_separate.stan",
                         data = list(N = length(y),y = y, sigma = sigma),
                         seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample_separate = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             theta_1 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[1]"]],
                             theta_2 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[2]"]],
                             theta_3 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[3]"]],
                             theta_4 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[4]"]],
                             theta_5 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[5]"]],
                             theta_6 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[6]"]],
                             theta_7 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[7]"]],
                             theta_8 = model_exercise5_3_separate@sim[["samples"]][[k]][["theta[8]"]],
                             model_type = 'separate_model'
  )
  
  params_sample_separate = rbind(params_sample_separate, current_chain)
  
}

## one merit of hierarchical model is that it borrows information from all the group, making the estimation of the parameter
## on each group has lower variance. 
 rbind(params_sample, params_sample_separate) %>%
  ggplot(aes(x= theta_6, color = model_type))+ geom_density()




