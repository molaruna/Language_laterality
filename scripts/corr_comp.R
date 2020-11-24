rm(list=ls())
library('tidyr')
library('DBI')
library('lazyeval')
library('ggplot2')
study_dir <- "/Users/mariaolaru/Google\ Drive/UCSF_personal/studies/Lang/"
mask <- "NS_ant"

extreme_val = F

BIP_path <- paste0(study_dir, "tables/table_Lang_LI_Feat_ind_allscansubs_", mask, "_BIP_noclust.csv")
FSL_path <- paste0(study_dir, "tables/table_Lang_LI_Feat_ind_allscansubs_", mask, "_BIP_thresh_noclust_8smoo.csv")

BIP_df <- read.csv(BIP_path)
BIP_df <- BIP_df[-c(60:61), -c(2:5, 7:8, 10:11, 13:14, 16:17)]
names(BIP_df) <- c("patID", "AT", "VG", "PL", "MR")

FSL_df <- read.csv(FSL_path)
FSL_df <- FSL_df[-c(60:61), -c(2:5, 7:8, 10:11, 13:14, 16:17)]
names(FSL_df) <- c("patID", "AT", "VG", "PL", "MR")

#Change extreme values to "NA"
if (extreme_val == F) {
  FSL_df[FSL_df == 1 | FSL_df == -1] <- NA
  BIP_df[BIP_df == 1 | BIP_df == -1] <- NA
}

BIP_df_long <- gather(BIP_df, task, BIP_LI, AT:MR)
FSL_df_long <- gather(FSL_df, task, FSL_LI, AT:MR)

meta_df <- cbind.data.frame(BIP_df_long, FSL_df_long[which(names(FSL_df_long) == 'FSL_LI')])

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

##graphs
graph_scatter <- ggplot(meta_df, aes(x=BIP_LI, y=FSL_LI, color=task)) +
  geom_point() + 
  geom_abline(intercept=0, slope=1) +
  labs(title = mask) +
  graph_format

graph_hist_BIP <- ggplot(meta_df) + geom_density(aes(x = BIP_LI, color=task)) + 
  graph_format +
  labs(title = paste(mask, "BIP"))
graph_hist_FSL <- ggplot(meta_df) + geom_density(aes(x = BIP_LI, color=task)) +
  graph_format +
  labs(title = paste(mask, "FSL"))

print(graph_scatter)
print(graph_hist_BIP)
print(graph_hist_FSL)

out_dir= paste0(study_dir,'graphs/')

svg(filename = (paste(out_dir,"corr_comp_", mask,".svg", sep = "")))
print(graph_scatter)
dev.off()

svg(filename = (paste(out_dir, "corr_comp_", mask, "_hist_BIP.svg", sep = "")))
print(graph_hist_BIP)
dev.off()

svg(filename = (paste(out_dir, "corr_comp_", mask, "_hist_FSL.svg", sep = "")))
print(graph_hist_FSL)
dev.off()





for (task in c("AT", "VG", "PL", "MR")) {
  FSL_corr <- FSL_df[ ,which(names(FSL_df) == task)]
  BIP_corr <- BIP_df[ ,which(names(BIP_df) == task)]
  cor_coef <- round(cor(FSL_corr, BIP_corr, use="complete.obs"), digits = 2)
  out <- paste("corr for", task, "is:", cor_coef)
  print(out)
}
