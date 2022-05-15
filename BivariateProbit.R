# Input the packages
library(readstata13)
library(dplyr)
library(rstan)
library(BBmisc)
library(VGAM)
library(purrr)
library(sampleSelection)
rstan_options(auto_write = TRUE)
options (mc.cores = parallel :: detectCores())

# Data Processing
var_1 = c('loginc','logptax','school')
var_2 = c('loginc','logptax','years','school')

df_raw =read.dta13('school.dta')
df_reg = df_raw %>%
  select (c('private','vote','loginc','logptax','school','years'))%>%
  mutate (const = 1)

# Prepare the data and model for estimation
data_input = list(
  N = nrow(df_reg),
  k_1 = length(var_1)+1,
  k_2 = length(var_2)+1,
  x_1 = df_reg %>% select (all_of (var_1), const),
  x_2 = df_reg %>% select (all_of (var_2),const),
  y = df_reg %>% select (c('private','vote'))
)

mod = stan_model ('BivariateProbit.stan')

# Model estimation.
# Result is stored in model_res
# when there is non-zero return code, set verbose = TRUE to check what is going on.
# sometimes the gradient become infinite
# therefore it seems safe to run the optimization multiple times.
set.seed(9)
model_res = NULL
model_value = -Inf
i = 1
while (i<30){
  temp = optimizing (mod, data = data_input,
                     #  verbose = TRUE,
                     hessian = TRUE, as_vector = FALSE)
  if (temp$value>model_value){
    model_res = temp
    model_value = temp$value
  }
  i = i+1
}
