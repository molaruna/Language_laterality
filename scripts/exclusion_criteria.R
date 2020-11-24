thresh_df = read.csv("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/list_thresh/list_zstat_99.csv")
task_list = c("AT", "VG", "PL", "MR")

exclusion_df = data.frame(matrix(NA, ncol = 5, nrow = 59))
colnames(exclusion_df) = c("patID", task_list)

for (s in 1:59) {
  subj_id = thresh_df$patID[s]
  thresh_subj = read.csv(paste0("/Users/mariaolaru/google_drive/LPN_personal/studies/Lang/list_thresh/exp_5_thresh/NS_full/list_thresholds_rel_thresh_mask_exp_5_NS_full_", subj_id, ".txt"))
  
  
  for (t in 1:4) {
    task = task_list[t]
    
    subj_thresh = thresh_df[which(thresh_df$patID==subj_id), ]
    
    add_thresh = sort(c(subj_thresh[[task]], thresh_0177$zstat))
    LI_thresh = which(add_thresh == subj_thresh[[task]])
    if (LI_thresh > 100) {
      LI_thresh = 100
    }
    
    exclusion_df$patID[s] = subj_id
    exclusion_df[s, t+1] = LI_thresh-1
  }
}

exclusion_formatted = data.frame(matrix(data = NA, nrow = 59, ncol = 5))
colnames(exclusion_formatted) = c("patID", task_list)

exclusion_formatted$sub_ID = thresh_df$patID
exclusion_formatted$AT <- lapply(exclusion_df$AT, function(x) paste0("AT.0", x, ".LI"))
exclusion_formatted$VG <- lapply(exclusion_df$AT, function(x) paste0("VG.0", x, ".LI"))
exclusion_formatted$PL <- lapply(exclusion_df$AT, function(x) paste0("PL.0", x, ".LI"))
exclusion_formatted$MR <- lapply(exclusion_df$AT, function(x) paste0("MR.0", x, ".LI"))