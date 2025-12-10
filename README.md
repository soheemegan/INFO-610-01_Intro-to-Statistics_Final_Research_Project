The Met Museum Acquisition Analysis (1900–2025)

25/FA-INFO-610 Intro to Statistics
Author: Megan Kim
Instructor: Prof. John Lauermann
Pratt Institute, School of Information

⸻

Overview

This project examines how The Metropolitan Museum of Art has built its collection over the last century, focusing on whether acquisitions rely more on private philanthropy (gifts, donations, bequests) or institutional purchases.

Using the Met’s Open Access dataset (455k+ objects), the analysis includes summary statistics, ANOVA, regression, chi-square testing, and visualizations (trend lines, boxplots, heatmaps, treemaps, alluvial diagrams). The goal is to understand how donor influence varies across departments and decades.

⸻

Research Question

Has The Met’s collection growth depended more on private philanthropy than on institutional purchases, and how has this changed across time and departments?

⸻

Repository Structure

met-acquisition-analysis/
│
├── met_acquisition_analysis.R        # Main analysis script (data cleaning, stats, plots)
│
├── data/
│   └── MetObjects.txt                # Met Open Access dataset (user downloads)
│
├── figures/                          # Exported visualizations
│   ├── 01_trend_philanthropy.png
│   ├── 02_boxplot_departments.png
│   ├── 03_alluvial_flows.png
│   ├── 04_treemap_acquisitions.png
│   ├── 05_heatmap_gift_ratios.png 
│   └── 06_ridgeline_distribution.png
│
└── README.md                         # Project documentation

⸻

Dataset

This project uses the Metropolitan Museum of Art Open Access Dataset, which includes metadata for over 470,000 artworks.

Download sources:
	•	Open Access portal: https://www.metmuseum.org/hubs/open-access
	•	GitHub repository: https://github.com/metmuseum/openaccess

Download MetObjects.txt and place it inside the data/ folder.

⸻

How to Reproduce the Analysis

1. Clone or download this repository
   git clone https://github.com/yourusername/met-acquisition-analysis.git
2. Install required R packages
   install.packages(c("dplyr", "ggplot2", "stringr", "ggalluvial", "treemapify", "ggridges"))
3. Run the script
   source("met_acquisition_analysis.R")

The script will load the dataset, classify acquisition types, compute ratios by decade and department, run statistical tests, and generate all visualizations.

⸻

Notes
	•	The dataset is large; some plots may take a moment to render.
	•	All analyses correspond to course requirements for 25/FA-INFO-610 Intro to Statistics.
