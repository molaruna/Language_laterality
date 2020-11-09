library(scales)
post_df = read.csv("~/google_drive/LPN_personal/studies/Lang/tables/Lang_postop_outcomes.csv")

post_df$clin.score.rescale = rescale(post_df$clin.score, to = c(-1, 1), from = range(post_df$clin.score, na.rm = TRUE, finite = TRUE))