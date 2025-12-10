###############################################################
# 25/FA-INFO-610: Intro to Statistics Final Project
# Project: The Met Museum Acquisition Analysis
# Author: Megan Kim
# Date: December 2025
#
# Goal:
#   Use the Met Open Access dataset to analyze how much the
#   museum relies on philanthropy (gifts, donations, bequests)
#   vs institutional purchases, across time and departments.
###############################################################


##############################
# 1. Load Libraries
##############################

library(dplyr)
library(ggplot2)
library(stringr)
library(ggalluvial)
library(treemapify)

# Optional (for extra visualization):
# install.packages("ggridges")   # run once manually if needed
# library(ggridges)


##############################
# 2. Load Dataset (Local Met Objects)
##############################

# NOTE: update file path if needed on another machine
met <- read.csv(
  "/Users/user/Desktop/MetObjects.txt",
  stringsAsFactors = FALSE
)

# Quick sanity check (can be commented out later)
head(met)
names(met)


##############################
# 3. Clean + Select Variables
##############################
# Keep only the variables needed for this project:
#   - Object.ID      : unique ID for each object
#   - Department     : curatorial department
#   - Credit.Line    : acquisition credit line (how it was funded)
#   - AccessionYear  : year of acquisition

met_clean <- met %>%
  dplyr::select(
    Object.ID,
    Department,
    Credit.Line,
    AccessionYear
  ) %>%
  mutate(
    AccessionYear = as.numeric(AccessionYear)
  ) %>%
  filter(
    !is.na(AccessionYear),
    AccessionYear >= 1900
  )

head(met_clean)


##############################
# 4. Create Acquisition Type
##############################
# Classify each acquisition as:
#   - "Philanthropy" if Credit.Line mentions gift / bequest / donation / donor
#   - "Purchase"    if Credit.Line mentions purchase
#   - "Other"       otherwise

met_clean <- met_clean %>%
  mutate(
    acq_type = case_when(
      grepl("Gift|Bequest|Donation|Donor", Credit.Line, ignore.case = TRUE) ~ "Philanthropy",
      grepl("Purchase", Credit.Line, ignore.case = TRUE)                    ~ "Purchase",
      TRUE                                                                  ~ "Other"
    )
  )

table(met_clean$acq_type)


##############################
# 5. Create Decade Variable
##############################
# Group years into decades (e.g. 1995 → 1990)

met_clean <- met_clean %>%
  mutate(
    decade = floor(AccessionYear / 10) * 10
  )

head(met_clean)


##############################
# 6. Build Summary Table (Dept x Decade)
##############################
# For each department + decade:
#   - total acquisitions
#   - number of philanthropic acquisitions
#   - number of purchases
#   - gift_ratio = gifts / total
#   - purchase_ratio = purchases / total

summary_table <- met_clean %>%
  group_by(Department, decade) %>%
  summarise(
    gifts          = sum(acq_type == "Philanthropy"),
    purchases      = sum(acq_type == "Purchase"),
    total          = n(),
    gift_ratio     = gifts / total,
    purchase_ratio = purchases / total,
    .groups        = "drop"
  )

head(summary_table)


##############################
# 7. ANOVA: Does Department Predict Gift Ratio?
##############################
# Test whether mean gift_ratio differs across departments.

anova_model <- aov(gift_ratio ~ Department, data = summary_table)
summary(anova_model)


##############################
# 8. Regression: Department + Time
##############################
# Multiple linear regression:
#   gift_ratio ~ Department + decade

summary_table$Department <- as.factor(summary_table$Department)

reg_model <- lm(gift_ratio ~ Department + decade, data = summary_table)
summary(reg_model)


##############################
# 9. Visualizations
##############################
# Simple, readable plots for the poster.
# You can export any of these with ggsave() later if needed.


## 9A. Trend Over Time -----------------------------------------
# Lines per department, plus overall trend line.

p_trend <- ggplot(
  summary_table,
  aes(x = decade, y = gift_ratio, group = Department, color = Department)
) +
  geom_line(alpha = 0.25) +
  geom_smooth(
    method = "loess",
    se     = FALSE,
    color  = "black",
    linewidth = 1
  ) +
  labs(
    title    = "Philanthropy Ratio Over Time at The Met",
    subtitle = "Each line = department; black curve = overall trend",
    x        = "Decade",
    y        = "Share of Acquisitions from Philanthropy"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none"
  )

p_trend


## 9B. Boxplot: Department Differences -------------------------
# Shows variation in gift_ratio across departments.

p_box <- ggplot(summary_table, aes(x = Department, y = gift_ratio)) +
  geom_boxplot(fill = "steelblue", alpha = 0.8) +
  labs(
    title    = "Differences in Philanthropy Reliance by Department",
    subtitle = "Each box shows the distribution of gift ratios across decades",
    x        = "",
    y        = "Gift Ratio"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
  )

p_box


## 9C. Alluvial Diagram: Flows Over Time -----------------------
# Decade → acquisition type → department

alluvial_decade <- met_clean %>%
  count(decade, acq_type, Department, name = "n")

p_alluvial <- ggplot(
  alluvial_decade,
  aes(axis1 = decade, axis2 = acq_type, axis3 = Department, y = n)
) +
  geom_alluvium(aes(fill = acq_type), alpha = 0.7) +
  geom_stratum(width = 0.1, fill = "white", color = "grey40") +
  geom_text(
    stat  = "stratum",
    aes(label = after_stat(stratum)),
    size  = 2.5,
    color = "black"
  ) +
  scale_x_discrete(
    limits = c("Decade", "Acquisition Type", "Department"),
    expand = c(.1, .1)
  ) +
  labs(
    title    = "Acquisition Flows Across Time and Departments",
    subtitle = "Decade → Acquisition Type → Department (1900–2025)",
    x        = "",
    y        = "Number of Acquisitions",
    fill     = "Acquisition Type"
  ) +
  theme_minimal(base_size = 11)

p_alluvial


## 9D. Treemap: Composition by Department ----------------------
# Shows relative size of each acquisition type within departments.

treemap_data <- met_clean %>%
  count(Department, acq_type, name = "n")

p_treemap <- ggplot(
  treemap_data,
  aes(
    area     = n,
    fill     = acq_type,
    label    = Department,
    subgroup = Department
  )
) +
  geom_treemap(color = "white") +
  geom_treemap_text(
    colour  = "white",
    place   = "centre",
    reflow  = TRUE,
    size    = 3
  ) +
  labs(
    title    = "Department-Level Composition of Acquisition Types",
    subtitle = "Relative dominance of philanthropy vs purchases",
    fill     = "Acquisition Type"
  )

p_treemap


## 9E. Heatmap: Philanthropy Dependence ------------------------
# Which departments depend most on philanthropy, by decade?

heatmap_data <- summary_table %>%
  mutate(
    Department = factor(Department),
    decade     = factor(decade)
  )

p_heatmap <- ggplot(
  heatmap_data,
  aes(x = decade, y = Department, fill = gift_ratio)
) +
  geom_tile(color = "white") +
  scale_fill_gradient(
    low  = "white",
    high = "steelblue",
    name = "Gift Ratio"
  ) +
  labs(
    title    = "Philanthropy Dependence Across Departments and Decades",
    subtitle = "Gift Ratio = gifts / total acquisitions",
    x        = "Decade",
    y        = "Department"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

p_heatmap


## 9F. Ridgeline: Distribution Over Time (Optional) ------------
# Only run this if you have ggridges installed & loaded.

# Uncomment if using ridgeline plot:
# ridge_data <- summary_table %>%
#   mutate(decade = factor(decade))
#
# p_ridge <- ggplot(
#   ridge_data,
#   aes(x = gift_ratio, y = decade, fill = decade)
# ) +
#   geom_density_ridges(alpha = 0.8, color = "white", scale = 1.2) +
#   labs(
#     title    = "Distribution of Philanthropy Reliance Over Time",
#     subtitle = "Each ridge = spread of gift ratios across departments in a decade",
#     x        = "Gift Ratio",
#     y        = "Decade"
#   ) +
#   theme_minimal(base_size = 11) +
#   theme(
#     legend.position = "none"
#   )
#
# p_ridge


##############################
# 10. Chi-Square Test (Optional)
##############################
# Test association between department and acquisition type
# (using only Philanthropy vs Purchase).

chisq_data <- met_clean %>%
  filter(acq_type %in% c("Philanthropy", "Purchase")) %>%
  count(Department, acq_type)

chisq_test_result <- chisq.test(
  xtabs(n ~ Department + acq_type, data = chisq_data)
)

chisq_test_result


##############################
# 11. Export Example (for Poster)
##############################
# Use ggsave() to export plots as PNG files.

# Example: export trend plot
# ggsave(
#   filename = "met_trend_philanthropy.png",
#   plot     = p_trend,
#   width    = 8,
#   height   = 5,
#   dpi      = 300
# )

