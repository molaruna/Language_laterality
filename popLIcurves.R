library('ggplot2')

#Clinical subgroups
clinical_df = read.csv("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/tables/subj_clinical_group.csv")

sublist_g0 = which(clinical_df$Group == 0)
sublist_g1 = which(clinical_df$Group == 1)
  
#Exclude data greater than 99th percentile of each subject's overall activation
thresh_df = read.csv("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/list_thresh/list_zstat_5smoo_99.csv")
task_list = c("AT", "VG", "PL", "MR")

exclusion_df = data.frame(matrix(NA, ncol = 5, nrow = 59))
colnames(exclusion_df) = c("patID", task_list)

for (s in 1:59) {
  subj_id = thresh_df$patID[s]
  thresh_subj = read.csv(paste0("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/list_thresh/exp_5_thresh/NS_full/list_thresholds_rel_thresh_mask_exp_5_NS_full_", subj_id, ".txt"))
  
  print(paste0("subject: ", s))
  
  for (t in 1:4) {
    task = task_list[t]
    
    subj_thresh = thresh_df[which(thresh_df$patID==subj_id), ]
    
    add_thresh = sort(c(subj_thresh[[task]], thresh_subj$zstat))
    LI_thresh = which(add_thresh == subj_thresh[[task]])[1]
    print(paste0("task: ", t))
    print(paste0("LI thresh: ", LI_thresh))
    
    if (LI_thresh >= 100) {
      LI_thresh = 99
    }
    
    exclusion_df$patID[s] = subj_id
    exclusion_df[s, t+1] = LI_thresh
  }
}

#Begin LI visualization
df = read.csv("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/table_Lang_LI_Feat_ind_allscansubs_NS_full_rel_thresh_mask_exp_5_noclust.csv")
df = df[1:59, ]

indx_LI = grep("LI", names(df))
LI_df = df[indx_LI]

#Remove values within exclusion criteria
for (s in 1:59) {
  LI_df[s, (exclusion_df$AT[s]+0):(100+0)] = NA
  LI_df[s, (exclusion_df$VG[s]+100):(100+100)] = NA
  LI_df[s, (exclusion_df$PL[s]+200):(100+200)] = NA
  LI_df[s, (exclusion_df$MR[s]+300):(100+300)] = NA
}

#Change remove threshold data with no active voxels
LI_df[LI_df == 0] = NA

#Remove LI percentile score if < 10 subjects with scores
na_count <-sapply(LI_df, function(y) sum(length(which(is.na(y)))))
LI_df[which(na_count > 49)] = NA

#LI table for subgroups
LI_df_g0 = LI_df[sublist_g0, ]
LI_df_g1 = LI_df[sublist_g1, ]



#Create summary table for analysis

#Function that creates mean and standard DF, error and CIs
summary_table = function(df_raw, alpha) {
  LI_df_proc = cbind.data.frame(perc = rep(1:100, 4), 
                                mean = colMeans(df_raw, na.rm=TRUE), 
                                sd = apply(df_raw, 2, function(x) sd(x, na.rm=TRUE)),
                                len = apply(df_raw, 2, function(x){ length(which(!is.na(x))) }))
  
  LI_df_proc$se = LI_df_proc$sd/LI_df_proc$len
  LI_df_proc$CI = (qt((1-alpha)/2 + 0.5, LI_df_proc$len-1))*LI_df_proc$se
  LI_df_proc$task = factor(c(rep("AT", 100), rep("VG", 100), rep("PL", 100), rep("MR", 100)))
  
  return(LI_df_proc)
}

LI_df_st = summary_table(LI_df, 0.01)
LI_df_g0_st = summary_table(LI_df_g0, 0.01)
LI_df_g1_st = summary_table(LI_df_g1, 0.01)

#Pretty graph formatting
graph_format <- theme_bw() +
  theme_light() +
  theme_minimal() + 
  theme(
    plot.title = element_text(size=24, face = "bold", hjust = 0.5), 
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18), 
    axis.title.x = element_text(size = 20), 
    axis.title.y = element_text(size = 20)
  )


LI_plot = ggplot(LI_df_st, aes(x = perc, y = mean, color = task)) + 
  geom_line(size=0.7) +
  geom_ribbon(aes(ymin = mean-CI, ymax = mean+CI, group = task, color = task, fill = task), linetype=0, alpha=0.3) +
  graph_format +
  ylim(-0.5, 1)
print(LI_plot)

svg(filename = ("/Users/mariaolaru/google_drive/LPN/Projects/Lang/figures/optLI_NSfull1.svg"))
print(LI_plot)
dev.off()

LI_plot_g0 = ggplot(LI_df_g0_st, aes(x = perc, y = mean, color = task)) + 
  geom_line(size=0.7) +
  geom_ribbon(aes(ymin = mean-CI, ymax = mean+CI, group = task, color = task, fill = task), linetype=0, alpha=0.3) +
  graph_format +
  ylim(-0.5, 1)
print(LI_plot_g0)

svg(filename = ("/Users/mariaolaru/google_drive/LPN/Projects/Lang/figures/optLIg0_NSfull1.svg"))
print(LI_plot_g0)
dev.off()

LI_plot_g1 = ggplot(LI_df_g1_st, aes(x = perc, y = mean, color = task)) + 
  geom_line(size=0.7) +
  geom_ribbon(aes(ymin = mean-CI, ymax = mean+CI, group = task, color = task, fill = task), linetype=0, alpha=0.3) +
  graph_format +
  ylim(-0.5, 1)
print(LI_plot_g1)

svg(filename = ("/Users/mariaolaru/google_drive/LPN/Projects/Lang/figures/optLIg1_NSfull1.svg"))
print(LI_plot_g1)
dev.off()



