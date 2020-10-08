library(tidyverse)
library(readxl)
library(dbplyr)
library(purrr)
library(plm)
library(tidymodels)
library(tidylog)
library(glue)
library(scales)
library(patchwork)
library(modelr)
library(broom)
library(openxlsx)
#-----regression on the whole data set---------------
# いろいろ説明変数の選択と入れ方を考えた
# we finally choose grp_value and grp_value:ei as explanatory variables
formulas = c(exact_awareness ~ grp_value+grp_value:ei,
             exact_awareness ~ log(grp_value)+log(grp_value):ei,
             awareness ~ grp_value+grp_value:ei,
             awareness ~ log(grp_value)+log(grp_value):ei) %>% 
  enframe("model_no", "formula")

reg_whole_fe = formulas %>% 
  mutate(model = map(formula, plm, data = df_reg, model='within',index=c("aggregated_cm_id","q_start")),
         tidied = map(model, tidy), 
         glanced = map(model, glance)) 

df_result

#------regression on different data set:awareness ~ grp_value+grp_value:ei----------------------

# this step helps split the data into different groups.
df_nested = df_reg %>% 
  group_by(segment_name) %>% 
  nest() %>% 
  arrange(segment_name)

# In reg_fe_grp, we consider awareness~grp_value+grp_value:ei with fixed effect
# reg_fe_grp  stores the estimation results for 20-40s and 50s-60s respectively
reg_fe_grp = df_nested %>% 
  mutate(moderu = map(data, ~plm(awareness ~ grp_value+grp_value:ei, data = ., model='within', index=c("aggregated_cm_id","q_start"))),
         tidied = map(moderu, tidy),
         glanced=map(moderu,glance))


# In reg_re_grp, we consider awareness~grp_value+grp_value:ei with random effect 
# reg_re_grp  stores the estimation results for 20-40s and 50s-60s respectively
reg_re_grp = df_nested%>% 
  mutate(moderu = map(data, ~plm(awareness ~ grp_value+grp_value:ei, data = ., model='random', index=c("aggregated_cm_id","q_start"))),
         tidied = map(moderu, tidy),
         glanced=map(moderu,glance))

# we finally use fixed effect esitmation results.

#phtest(reg_fe_grp[[3]][[1]],reg_re_grp[[3]][[1]])
#phtest(reg_fe_grp[[3]][[2]],reg_re_grp[[3]][[2]])
#$phtest(reg_fe_loggrp[[3]][[1]],reg_re_loggrp[[3]][[1]])
#phtest(reg_fe_loggrp[[3]][[2]],reg_re_loggrp[[3]][[2]])



# We now do visualization. 
dfreg1=df_reg%>%
  filter(segment_name=='男女20-40代')
# The model specification is:
# awareness(i,t)=alpha_i+(beta+gamma*VI(i)*AI(i))*GRP(i,t)+epsilon(i,t)
#-----------visualization 1：GRPの認知度獲得率とVI*AIの関係---------------------
stat_matrix=reg_fe_grp[[4]][[1]]
coef1=as.numeric(stat_matrix[1,2])  # coef1 is beta
coef2=as.numeric(stat_matrix[2,2])  # coef2 is gamma

# plot (coef1+coef2*VI*AI)-(VI*AI) curve
ei_seq=seq(min(dfreg1$ei), max(dfreg1$ei), length=20)　# Generate a sequence of VI*AI
df_effect=data.frame(ei_seq ) 
df_effect=df_effect%>%
  mutate(effect=1000*(ei_seq*coef2+coef1))

plot_result1=ggplot(data=df_effect, aes(x=ei_seq, y=effect)) +
  geom_line()+xlab('VI*AI')+ylab('認知獲得効率')+
  labs(title = "認知獲得効率（grp1000増し）とVI*AI の関係
")+
  theme_bw(base_family = "HiraKakuProN-W3") 

print(plot_result1) 

#--------- visualization 2----------------------
# Now we want to plot awareness-grp_value curve by fixing VI*AI
# Awareness=coef1*grp_value+coef2*grp_value*VI*AI
# We  plot a wareness-grp_value curve using a average VI*AI

benchmark_ei=mean(dfreg1$ei) # the average VI*AI turns out to be 0.65

# create a vector of grp_value
grp_seq=seq(min(dfreg1$grp_value), max(dfreg1$grp_value), length=30)
df_plot1=data.frame(grp_seq ) 
df_plot2=df_plot1%>%
  mutate(awareness_seq=grp_seq*benchmark_ei*coef2+grp_seq*coef1)%>%
  mutate(Case='VI*AI=0.65')

# we also plot a awareness-grp_value curve, where the VI*AI raises from average value by 15%
df_plot3=df_plot1%>%
  mutate(awareness_seq=grp_seq*benchmark_ei*1.15*coef2+grp_seq*coef1)%>%
  mutate(Case='VI*AI=0.65*(1+15%)')

df_plot=rbind(df_plot2,df_plot3)

plot_result2=ggplot(data=df_plot, aes(x=grp_seq, y=awareness_seq, group=Case, color=Case)) +
  geom_line()+xlab('累計GRP')+ylab('認知度(%)')+
  theme_bw(base_family = "HiraKakuProN-W3") 
 
print(plot_result2) 

# --------visualization 3--------
# For each cm, we plot the change of awareness from a grp 1000 increase 

dfreg_bycm=dfreg1%>%
  mutate(awareness_change=(coef2*ei+coef1)*1000)%>%
  group_by(aggregated_cm_id,type,cm_name)%>%
  summarise(
    awareness_change=mean(awareness_change)
  )
dfreg_bycm=as.data.frame(dfreg_bycm)

plot_result3=ggplot(data=dfreg_bycm, aes(x=cm_name, y=awareness_change,fill=type)) +
  geom_bar(stat='identity')+xlab('素材名')+ylab('grpが1000増加するに当たる認知の絶対変動(%)
')+coord_flip()+
  theme_bw(base_family = "HiraKakuProN-W3") 

# fill=type means that we plot different colors for different cm type: cancer or medical. 

print(plot_result3)

# --------Visualization 4--------
# Using a graph, we show that the data for 50-60 is not sufficient to make valid analysis
dfreg2=df_reg%>%
  filter(segment_name=='男女50-60代')

df5060=dfreg2%>%
  group_by(cm_name)%>%
  summarise(
    record=n()
  )
df5060=as.data.frame(df5060)

plot_result4=ggplot(data=df5060, aes(x=cm_name, y=record)) +
  geom_bar(stat='identity')+xlab('素材名')+ylab('記録数
')+coord_flip()+
  theme_bw(base_family = "HiraKakuProN-W3") # this command is to show japanese.

# fill=type means that we plot different colors for different cm type: cancer or medical. 

print(plot_result4)

#-----------visualization 5---------------------
# In this part, we run the regression under different grp thresholds.
# The purpose for this exercise is for robustness check
#  We set grp threshold to 310,350,390,430,470
threshold_seq=seq(310, 470, length=5)
coef1_v5=vector()
coef2_v5=vector()
coef1_pvalue=vector()
coef2_pvalue=vector()
for (i in threshold_seq){
  grp_threshold=i
  df_reg_v5=df_awareness%>%
    mutate(grp_value=as.numeric(map2(aggregated_cm_id,q_end,grp_cal)))%>%
    mutate(vi_value=vi_cal(aggregated_cm_id,segment_name))%>%
    mutate(ai_value=ai_cal(aggregated_cm_id,segment_name))%>%
    mutate(ei=ai_value*vi_value)
  
  df_nested_v5 = df_reg_v5 %>% 
    group_by(segment_name) %>% 
    nest() %>% 
    arrange(segment_name)
  
  reg_fe_grp_v5 = df_nested_v5 %>% 
    mutate(moderu = map(data, ~plm(awareness ~ grp_value+grp_value:ei, data = ., model='within', index=c("aggregated_cm_id","q_start"))),
           tidied = map(moderu, tidy),
           glanced=map(moderu,glance))
  
  stat_matrix_v5=reg_fe_grp_v5[[4]][[1]]
  # this matrix stores the statistics for each variables
  coef1_v5=append(coef1_v5,as.numeric(stat_matrix_v5[1,2])) # coef1_v5 stores the beta estimations for five threshold values.
  coef2_v5=append(coef2_v5,as.numeric(stat_matrix_v5[2,2])) # coef2_v5 stores the gamma estimations for five threshold values.
  coef1_pvalue=append(coef1_pvalue,as.numeric(stat_matrix_v5[1,5])) # this stores the p-values for each coef1
  coef2_pvalue=append(coef2_pvalue,as.numeric(stat_matrix_v5[2,5])) # this stores the p-values for each coef2
  }
# Now we have the regression results under five threshold_value:310,350,390,430,470
# We show the estimation results on a table.
options(digits=3)
table_result=as.data.frame(cbind(threshold_seq,coef1_v5,coef2_v5))
table_result=table_result%>%
  rename( beta=coef1_v5,gamma=coef2_v5,'累計grp目安'=threshold_seq)
write.xlsx(table_result, file="/Users/l.xu/Desktop/v5.xlsx")

# ---------visualization 6------------
#consider the exact awareness as dependent variable-------
#run the regression, and compare the result with the benchmark case
grp_threshold=430 # since in the visualization 5 we changed the value of grp_threshold, here we need to change it back to the benchmark value 430
reg_fe_grp_exact = df_nested %>% 
  mutate(moderu = map(data, ~plm(exact_awareness ~ grp_value+grp_value:ei, data = ., model='within', index=c("aggregated_cm_id","q_start"))),
         tidied = map(moderu, tidy),
         glanced=map(moderu,glance))

stat_matrix_exact=reg_fe_grp_exact[[4]][[1]]
coef1_exact=as.numeric(stat_matrix_exact[1,2]) # beta
coef2_exact=as.numeric(stat_matrix_exact[2,2]) # gamma

df_effect_exact=data.frame(ei_seq ) 
df_effect_exact=df_effect_exact%>%
  mutate(effect=1000*(ei_seq*coef2_exact+coef1_exact), Type='確かに見た')

df_effect_all=df_effect%>%
  mutate(Type='確かに見た+多分見た') # this is the benchmark model.

df_effect_v6=rbind(df_effect_all,df_effect_exact)

plot_result6=ggplot(data=df_effect_v6, aes(x=ei_seq, y=effect, group=Type, linetype=Type)) +
  geom_line()+xlab('VI*AI')+ylab('認知獲得効率')+
  labs(title = "認知獲得効率（grp1000増し）とVI*AI の関係
")+
  theme_bw(base_family = "HiraKakuProN-W3") 

print(plot_result6) 


