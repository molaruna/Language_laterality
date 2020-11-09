library("ggpubr")

LI_df = read.csv("~/google_drive/LPN_personal/studies/Lang/tables/table_Lang_LI_Feat_ind_allscansubs_NS_cort_rel_thresh_mask_exp_5_noclust.csv")
LI_BIP_df = read.csv("~/google_drive/LPN_personal/studies/Lang/tables/Lang_BIP_LI_sublist.csv")  

clin_df = read.csv("~/google_drive/LPN_personal/studies/Lang/tables/Lang_clin_lat_scores_noPL.csv")

LI_df_thresh = cbind.data.frame(LI_df$VG.051.LI[1:59], LI_df$MR.051.LI[1:59])
sub_list = LI_df$patID[1:59]

LI_BIP_df_thresh = cbind.data.frame(LI_BIP_df$VG.LI, LI_BIP_df$MR.LI)


LI_df_thresh$LI_avg = rowMeans(LI_df_thresh, na.rm = TRUE)
LI_df_thresh$LI_BIP_avg = rowMeans(LI_BIP_df_thresh)
LI_df_thresh$clin_avg = clin_df$overall_avg
LI_df_thresh$patID = LI_df$patID[1:59]

cor(LI_df_thresh$LI_avg, LI_df_thresh$clin_avg)

write.csv(LI_df_thresh, "~/google_drive/LPN_personal/studies/Lang/tables/opt_LI.csv")

