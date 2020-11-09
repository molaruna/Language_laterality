WADA_df = read.csv("~/google_drive/LPN/Projects/Lang/Tables/CSV/WADA_comp.csv")

WADA_df$WADA = factor(WADA_df$WADA, levels = c("R hemi", "L >> R hemi", "L hemi"))
WADA_df$LI.FEAT.laterality = factor(WADA_df$LI.FEAT.laterality, levels = c("L hemi", "R hemi"))

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

WADA_bar = ggplot(data=WADA_df, aes(x=WADA, fill=LI.FEAT.laterality)) + 
  geom_bar(stat="count") +
  graph_format + 
  xlab("wada result") +
  ylab("count") +
  ggtitle("WADA comparison")
  
svg(filename = ("~/google_drive/LPN/Projects/Lang/figures/WADA_comp_bar.svg"))
print(WADA_bar)
dev.off()

print(WADA_bar)