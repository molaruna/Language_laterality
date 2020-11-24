library(ggplot2)

postop_df = read.csv("~/google_drive/LPN/Projects/Lang/Tables/CSV/postop_complications.csv")

postop_df$condition_code = factor(postop_df$condition_code, levels = c("epilepsy", "mass/AVM"))
postop_df$complication_code = factor(postop_df$complication_code, levels = c("complications", "no complications"))

postop_df$percentage_overlap = postop_df$overlap.mm3./postop_df$LI_mask.mm3.

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

comp_scatter = ggplot(postop_df, aes(x=resection.mm3., y=overlap.mm3., color=complication_code)) + 
  geom_point(aes(shape=condition_code), alpha = 0.8, na.rm=TRUE, position = position_dodge(width=0.9)) +
  graph_format +
  xlab("resection (mm3)") +
  ylab("overlap (mm3)") +
  ggtitle("Comparison of Postoperative Outcomes")
  #geom_hline(yintercept=0, linetype="dashed", color = '#7D170F', size=1) +
  #geom_vline(xintercept=0, linetype="dashed", color = '#7D170F', size=1) +


svg(filename = ("~/google_drive/LPN/Projects/Lang/figures/postop_outcomes_masks_resection.svg"))
print(comp_scatter)
dev.off()

print(comp_scatter)

#Wilcoxon Tests
comp_overlap = postop_df$overlap.mm3.[postop_df$complication_code=="complications"]
nocomp_overlap = postop_df$overlap.mm3.[postop_df$complication_code=="no complications"]

wilcox.test(comp_overlap, nocomp_overlap)

comp_overlap_mass = postop_df$overlap.mm3.[postop_df$complication_code=="complications" & postop_df$condition_code=="mass/AVM"]
nocomp_overlap_mass = postop_df$overlap.mm3.[postop_df$complication_code=="no complications" & postop_df$condition_code=="mass/AVM"]

wilcox.test(comp_overlap_mass, nocomp_overlap_mass)
