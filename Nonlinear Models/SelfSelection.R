# Input the package 
library(readstata13)
library(dplyr)
library(rstan)
library(BBmisc)
library(VGAM)
library(purrr)
rstan_options(auto_write = TRUE)
options (mc.cores = parallel :: detectCores())

# Input the data
df_reg =read.dta13('labor.dta')%>%
  mutate (wc = ifelse (we>12,1,0))%>%
  mutate (const = 1)

# Input the model and data_input for training.
mod = stan_model ('SelfSelection.stan')
data_input = list(
  N = nrow(df_reg), 
  k_1 = length(c('wmed','wfed'))+1, 
  k_2 = length(c('wa','cit','wc')) +1,
  x_1 = df_reg%>%select(c('wmed','wfed','const')),
  x_2 = df_reg%>%select (c('wa','cit','wc','const')),
  D = df_reg$wc,
  y = df_reg$ww
)

# Estimate the model using MLE
# Set verbose= TRUE to confirm that we do successfully get the estimation.
# The result is stored in model_res
set.seed(9) 
model_res = NULL
model_value = -Inf
i = 1
while (i<50){
  temp = optimizing (mod, data = data_input,
                     verbose = TRUE,
                     hessian = TRUE, as_vector = FALSE)
  if (temp$value>model_value){
    model_res = temp
    model_value = temp$value
  }
  i = i+1
}
