# Input the packages
library(readstata13)
library(dplyr)
library(rstan)
library(BBmisc)
library(VGAM)
library(purrr)
rstan_options(auto_write = TRUE)
options (mc.cores = parallel :: detectCores())

# Data Processing
df_raw =read.dta13('womenwk.dta')
var_list = c('age', 'married', 'children', 'education')
df_reg = df_raw%>%
  select (all_of(var_list),work)%>%
  mutate (const = 1) 

# try with vgm package 
eqs= reduce(var_list, function(a,b) paste(a,b,sep = '+'))%>%
  paste0('lwf~', .)%>%eval(.)
tobit.model <- vglm(eqs,
                     tobit(Lower=0),data = df_reg)

# try with rstan. Input the model and data for training.
mod = stan_model ('HeteroProbit.stan')
data_input = list(
  N = nrow(df_reg), 
  K_x = length(var_list)+1, 
  K_z = length(var_list) ,
  x = df_reg%>%select(-work),
  z = df_reg%>%select (all_of(var_list)),
  y = df_reg$work
)
set.seed(99) 

# Start training. The result is in model_res
model_res = NULL
model_value = -Inf
i = 1
while (i<30){
  temp = optimizing (mod, data = data_input,
                    # verbose = TRUE,
                     hessian = TRUE, as_vector = FALSE)
  if (temp$value>model_value){
    model_res = temp
    model_value = temp$value
  }
  i = i+1
}

