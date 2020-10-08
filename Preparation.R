library(tidyverse)
library(readxl)
library(dbplyr)
library(purrr)
library(plm)
library(tidymodels)

# Input the data of awarness　データを読み込む
filepath='/Users/l.xu/Desktop/awareness_aflac.xlsx'
df_awareness=read_excel(filepath, sheet=3,col_names=TRUE)
# Input the data of the id_logs from the data base.
filepath='/Users/l.xu/Desktop/id_logs_aflac.xlsx'
df_id_logs=read_excel(filepath, sheet=1,col_names=TRUE)

# turn the the date variable into 'date' type, and take out variables that we want.
df_awareness=df_awareness%>%
  mutate(q_start=as.Date(question_start), q_end=as.Date(question_end))%>%
  select(-c(question_start, question_end))

df_awareness=na.omit(df_awareness)

df_id_logs=df_id_logs%>%
  mutate(cm_started_date=as.Date(cm_started_date_29h))%>%
  select(aggregated_cm_id,cm_log_id,cm_started_date, segment_name,cm_log_reach,pw,pv,w,v,e,cm_log_grp,cum_cm_log_grp,vi,ai,ei,base_vi,base_ai,base_ei)

#grpが430に達する時点でのVI*AI数値を求めるので、grp_threholdどいう変数を作る
grp_threshold=430

#-------------------function definition part-------------------------------
# 回帰分析に使えるデータを作るために、二つの表をくっつける必要がある
#　そのため、以下の関数を作っておく。
# for a　given aggregated_cm_id and  q_int
# find out the accmulative grp(i,t) from the starting date of cm broadingcast till the question date
# grp_cal 関数は、ある素材cm_id_inputが放送開始時点からq_input時点までの累計grpを算出
grp_cal=function(cm_id_input,q_input){
  df_temp = df_id_logs%>%
    filter(cm_started_date<=q_input)%>%  #q_input時点までの記録だけを選ぶ
    filter(aggregated_cm_id==cm_id_input)　#cm_id_input素材の記録だけを選ぶ
  return(max(df_temp$cum_cm_log_grp))　#選んだ記録の中で最も大きい累計grPを見つける
}

#for a given cm_id_input and segment_name_input, find out vi when accumulative grp reaches grp_threshold
# vi_cal 関数は、ある素材cm_id_inputが放送開始時点からgrpが430に達する時点までsegment_name_input世帯における累計VIを算出
vi_cal=function(cm_id_input, segment_name_input){
  
  df_temp = df_id_logs%>%
    filter(aggregated_cm_id==cm_id_input)%>% #cm_id_input素材の記録だけを選ぶ
    filter(segment_name==segment_name_input)#segment_name_inputにおける記録だけを選ぶ
  
  flag=any(df_temp$cum_cm_log_grp>=grp_threshold)　#まずは、df_tempにはgrp_threshold (430)の累計grpに達する記録が存在するかを確認
  if (flag==TRUE){　#ある場合
    grp_reaches=min(df_temp$cum_cm_log_grp[df_temp$cum_cm_log_grp>=grp_threshold])
    df_temp_temp=df_temp%>%
      filter(cum_cm_log_grp<=grp_reaches)
    # find out all the records where the accumulated grp have not reached grp_threshold (430)
    #Now we calcualte the VI.The formula is: VI=((v/PV)/(W/PW))/BASE_VI
    vi=sum(df_temp_temp$v)
    vi=sum(df_temp_temp$v)/sum(df_temp_temp$pv)
    vi=vi/(sum(df_temp_temp$w)/sum(df_temp_temp$pw))
    vi=vi/mean(df_temp_temp$base_vi)
  }else{
    #ない場合
    vi=0
  }
  return(vi)
}

vi_cal=Vectorize(vi_cal)　# mutateにこのvi＿cal関数を使えるようにべくトライズする

#for a given cm_id_input and segment_name_input, find out AI when accumulative grp reaches grp_threshold
# AI_cal 関数は、ある素材cm_id_inputが放送開始時点からgrpが430に達する時点までsegment_name_input世帯における累計AIを算出

ai_cal=function(cm_id_input, segment_name_input){
  df_temp = df_id_logs%>%
    filter(aggregated_cm_id==cm_id_input)%>%
    filter(segment_name==segment_name_input)
  
  flag=any(df_temp$cum_cm_log_grp>=grp_threshold)
  if (flag==TRUE){
    grp_reaches=min(df_temp$cum_cm_log_grp[df_temp$cum_cm_log_grp>=grp_threshold])
    #AI=(E/V)/BASE_AI
    df_temp_temp=df_temp%>%
      filter(cum_cm_log_grp<=grp_reaches)
    ai=sum(df_temp_temp$e)/sum(df_temp_temp$v)
    ai=ai/mean(df_temp_temp$base_ai)
  }else{
    ai=0
  }
  return(ai)
}
ai_cal=Vectorize(ai_cal)

#----------get the data that can be used in regression----------
#以上の関数を使って、認知度データdf_awarenessにて：
df_reg=df_awareness%>%
  mutate(grp_value=as.numeric(map2(aggregated_cm_id,q_end,grp_cal)))%>% # aggregated_cm_idのある調査回の終了日までの累計grpを算出
  mutate(vi_value=vi_cal(aggregated_cm_id,segment_name))%>%　# aggregated_cm_id,segment_nameごとのVIを算出
  mutate(ai_value=ai_cal(aggregated_cm_id,segment_name))%>%　# aggregated_cm_id,segment_nameごとのAIを算出
  mutate(ei=ai_value*vi_value) # EIを算出

#df_regを使って回帰分析をする

