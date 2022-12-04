library(dplyr)
library(ggplot2)

joint_distribution = function (y, utah, nevada, others){
  # this is for compute pr(y1,....y8)
  # since we do not know which states these data come from, we need to compute the joint distribution under each possible assignment
  # and finally take average.
  n = length(y)
  prob = rep(0,n)
  prob_vec = NULL
  for (i in 1:(n-1)){
    for (j in (i+1):n){
      prob[i] = dnorm(y[i], utah, 1) # assign one data to utah
      prob[j] = dnorm(y[j], nevada, 1) # assign another data to nevada
      prob[-c(i,j)]  = dnorm(y[-c(i,j)], others, 1) # the remaining belong to others
      prob_vec = c(prob_vec,prod(prob)) # compute the joint distribution under the current assignment and save it
    }
  }
  return(mean (prob_vec)) # finshed computing pr(y1,...y8)
}

y=c(5.8, 6.6, 7.8, 5.6, 7.0, 7.1, 5.4) # only know 7 points
utah = 5 # mean of utah
nevada = 10 # mean of nevada
others = 6 # mean of others
# now compute pr(y8|y1,...y7) , which is proportion to pr(y1,....y8)
y8=3
prob_y8 = NULL
while (y8<15){
  y_cur = c(y, y8) # the full data of the eight points
  prob_y8 = c(prob_y8, joint_distribution(y_cur,utah, nevada,others))
  y8 = y8 + 0.25
}

data.frame(prob_y8 = prob_y8/sum(prob_y8)) %>% # normalization
  ggplot(aes(x = prob_y8)) + geom_density()
