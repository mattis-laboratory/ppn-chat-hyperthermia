# PPN - means mixed modeling for Figure 3C
# Comparison of means during  heating and seizure (and against baseline) 
# Within and across genotype (WT, het)

# ============================================================
# Group x Time analysis for calcium signal (z-scored, baseline = 0)
# ============================================================

library(dplyr)
library(tidyr)
library(lme4)
library(lmerTest)   # gives p-values for lmer via Satterthwaite df
library(emmeans)

# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------
# Each table should have one row per mouse, with columns: mouse_id, heat, seizure, group

# ------------------------------------------------------------

# Keep only datasets
rm(list = setdiff(ls(), c("het_data", "WT_data")))


df_wide <- bind_rows(WT_data, het_data)

# Make mouse IDs globally unique (in case IDs repeat across genotype tables)
df_wide$mouse_id <- paste(df_wide$group, df_wide$mouse_id, sep = "_")

# ------------------------------------------------------------
# 2. RESHAPE TO LONG FORMAT
# ------------------------------------------------------------
df_long <- df_wide %>%
  pivot_longer(cols = c(heat, seizure), names_to = "time", values_to = "signal") %>%
  mutate(
    group = factor(group, levels = c("WT", "het")),   # set reference order
    time  = factor(time,  levels = c("heat", "seizure"))
  )

# ------------------------------------------------------------
# 3. FIT MIXED-EFFECTS MODEL (baseline excluded — it's a fixed 0, not "data")
# ------------------------------------------------------------
model <- lmer(signal ~ group * time + (1 | mouse_id), data = df_long)

summary(model)          # coefficients
anova(model)            # omnibus test of group, time, group:time (interaction = "do groups differ in how they change over time")

# ------------------------------------------------------------
# 4. ESTIMATED MARGINAL MEANS
# ------------------------------------------------------------
emm <- emmeans(model, ~ group * time)
emm   # print estimated cell means with SEs and CIs

# ------------------------------------------------------------
# 5. THREE CONTRAST FAMILIES
# ------------------------------------------------------------

# (a) Each cell mean vs 0  --> equivalent to "vs baseline" since baseline == 0
vs_zero <- test(emm, null = 0)
vs_zero_df <- as.data.frame(vs_zero) %>%
  rename(estimate = emmean) %>%
  mutate(comparison = paste(group, time, "vs baseline"),
         family = "vs_baseline") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# (b) heat vs seizure — within each group
time_contrasts <- contrast(emm, method = "revpairwise", by = "group")
tc_df <- as.data.frame(time_contrasts) %>%
  mutate(comparison = paste(group, contrast),
         family = "within_group_time") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# (c) Group vs group, within each time period
group_vs_group <- contrast(emm, method = "pairwise", by = "time")
gvg_df <- as.data.frame(group_vs_group) %>%
  mutate(comparison = paste(time, contrast),
         family = "group_vs_group") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# ------------------------------------------------------------
# 6. COMBINE ALL COMPARISONS INTO ONE FAMILY AND CORRECT ONCE
# ------------------------------------------------------------
all_results <- bind_rows(vs_zero_df,tc_df, gvg_df) %>%
  mutate(p_adj_BH   = p.adjust(p.value, method = "BH"),
         p_adj_holm = p.adjust(p.value, method = "holm")) %>%
  arrange(family, p.value)

print(all_results, digits = 4)

# ------------------------------------------------------------
# 7. ADD SIGNIFICANCE STARS + PRINT RESULTS
# ------------------------------------------------------------

p_to_stars <- function(p) {
  case_when(
    p < 0.0001 ~ "****",
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    TRUE      ~ ""
  )
}

all_results <- all_results %>%
  mutate(sig_BH   = p_to_stars(p_adj_BH),
         sig_holm = p_to_stars(p_adj_holm))

cat("Significance: * p<0.05, ** p<0.01, *** p<0.001, **** p<0.0001 (adjusted)\n")
print(all_results, digits = 4)



