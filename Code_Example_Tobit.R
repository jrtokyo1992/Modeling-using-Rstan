library(readstata13)
library(dplyr)
library(rstan)
library(BBmisc)
library(VGAM)
library(purrr)

df_raw =read.dta13('womenwk.dta')

var_list = c('age', 'married', 'children', 'education')

df_reg = df_raw%>%
  select (all_of(var_list),lwf)%>%
  mutate (const = 1) 

# try with vgm package 
eqs= reduce(var_list, function(a,b) paste(a,b,sep = '+'))%>%
  paste0('lwf~', .)%>%eval(.)
tobit.model <- vglm(eqs,
                     tobit(Lower=0),data = df_reg)

# try with rstan
mod = stan_model ('censored.stan')
data_input = list(
  N = nrow(df_reg), 
  K = length(var_list)+1, 
  x = df_reg%>%select(-lwf)%>%as.matrix.data.frame(.),
  y = df_reg$lwf
)
set.seed(99) 
model_res = optimizing (mod, data = data_input, hessian = TRUE, as_vector = FALSE)


