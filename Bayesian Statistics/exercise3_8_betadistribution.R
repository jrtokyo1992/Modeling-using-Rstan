
library(dplyr)
library(rstan)
library(ggplot2)

N1 = 10
y1= c(16/58, 9/90, 10/48, 13/57, 19/103,20/57, 18/86, 17/112, 35/273, 55/64)
y1 = y1/(y1+1)
N2 = 8
y2= c(12/113, 1/18, 2/14, 4/44, 9/208,7/67, 9/29, 8/154)
y2 = y2/(y2+1)


warmup = 2000
iter = 4000
chains = 4
thin = 4

model_exercise3_8 = stan(file = "exercise3_8.stan",
                         data = list(
                           y1 = y1, y2= y2, N1=N1, N2 = N2 
                         ),
                         seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)


params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                             u_1 = model_exercise3_8@sim[["samples"]][[k]][["u_1"]], 
                           ##  alpha_1 = model_exercise3_8@sim[["samples"]][[k]][["alpha_1"]],
                           ##  alpha_1 = model_exercise3_8@sim[["samples"]][[k]][["alpha_1"]],
                             u_2 = model_exercise3_8@sim[["samples"]][[k]][["u_2"]]
                           ##  alpha_2 = model_exercise3_8@sim[["samples"]][[k]][["alpha_2"]],
                             
                            # pred_y = model_exercise3_5_noerror@sim[["samples"]][[k]][["z"]]
                             
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}



params_sample %>% filter (time >= warmup/thin) %>% 
  mutate (u_diff = u_1-u_2) %>%
  ggplot(aes(x = u_diff)) + geom_density()


######## binomial hierarichical model 

N1 = 10
y1= c(16, 9, 10, 13, 19,20, 18, 17, 35, 55)
num_1 = c(74,99, 58, 70,122,57,104,129,308,119)
N2 = 8
y2= c(12, 1, 2, 4, 9,7, 9, 8)
num_2 = c(125,19,16,48,217,74,38,162)

warmup = 2000
iter = 4000
chains = 4
thin = 4

model_bicycle_traffic_hierarchical = stan(file = "bicycle_traffic.stan",
                         data = list(
                           y1 = y1, y2= y2, N1=N1, N2 = N2, num_1 = num_1, num_2 = num_2
                         ),
                         seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)

params_sample = NULL
for (k in 1:chains) {
  
  current_chain = data.frame(time = 1:(iter/thin), chain = k,
                            theta_1_1 =  model_bicycle_traffic_hierarchical@sim[["samples"]][[k]][["theta_1[1]"]], 
                        
                            theta_1_2 =  model_bicycle_traffic_hierarchical@sim[["samples"]][[k]][["theta_1[2]"]]
                             
  )
  
  params_sample = rbind(params_sample, current_chain)
  
}


params_sample %>% filter (time >= warmup/thin) %>% 
  ggplot(aes(x = theta_1_2)) + geom_density()


###### hierarchical poisson distribution.

N1 = 10
y1= c(16, 9, 10, 13, 19,20, 18, 17, 35, 55)
num_1 = c(74,99, 58, 70,122,57,104,129,308,119)
N2 = 8
y2= c(12, 1, 2, 4, 9,7, 9, 8)
num_2 = c(125,19,16,48,217,74,38,162)
y1 = num_1 - y1
y2 = num_2 - y2

warmup = 2000
iter = 4000
chains = 4
thin = 4

model_bicycle_traffic_hierarchical_poisson = stan(file = "bicyle_traffic_poisson.stan",
                                          data = list(
                                            y1 = y1, y2= y2, N1=N1, N2 = N2
                                          ),
                                          seed = 1, chains = 4, iter = iter, warmup = warmup, thin = thin
)


