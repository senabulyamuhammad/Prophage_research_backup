# List the CSV files
list.files("csv formats data")

# Load the prophage region data
prophages <- read.delim(
  "prophage_regions.tsv",
  header = TRUE,
  sep = "\t"
)

#chacking loaded data
dim(prophages)
head(prophages)
str(prophages)

#installing and loading readxl library (TO HELP ME READ MY .XLSX DATA FILES)
if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}

library(readxl)


# Set the working directory
setwd("~/Desktop/Prophage_research")

# Load the four Excel tables
prophage_distribution <- read_excel(
  "Destribution of predicted prophage regions.xlsx"
)

amr_matches <- read_excel(
  "AMR Associated gene matched_ABRicate.xlsx"
)

genomic_overlap <- read_excel(
  "GENOMIC OVERLAP BETWEEN AMR-ASSOCIATED MATCHES AND PREDICTED PROPHAGE REGIONS.xlsx"
)

integrated_comparison <- read_excel(
  "INTEGRATED COMPARISON OF PROPHAGE AND AMR SCREENING RESULTS.xlsx"
)

# Confirm successful loading
dim(prophage_distribution)
dim(amr_matches)
dim(genomic_overlap)

dim(integrated_comparison)

# View column names
names(prophage_distribution)
names(amr_matches)
names(genomic_overlap)
names(integrated_comparison)

# Inspect the first rows
head(prophage_distribution)
head(amr_matches)
head(genomic_overlap)
head(integrated_comparison)


# Clean Table 1
prophage_distribution <- readxl::read_excel(
  "Destribution of predicted prophage regions.xlsx",
  skip = 1,
  col_names = c(
    "Genome", "Prophage_Count", "Total_Length_bp",
    "Mean_Length_bp", "Transposable_Count"
  )
)

# Remove the TOTAL row for genome-to-genome plots
prophage_plot_data <- subset(
  as.data.frame(prophage_distribution),
  Genome != "TOTAL"
)

# Convert measurement columns to numeric
numeric_cols <- c(
  "Prophage_Count", "Total_Length_bp",
  "Mean_Length_bp", "Transposable_Count"
)

prophage_plot_data[numeric_cols] <- lapply(
  prophage_plot_data[numeric_cols],
  as.numeric
)

# Check the cleaned data
print(prophage_plot_data)
str(prophage_plot_data)

# Remove the repeated header row and any TOTAL row
prophage_plot_data <- subset(
  prophage_plot_data,
  !Genome %in% c("GENOME", "TOTAL")
)

# Confirm the cleaned data
print(prophage_plot_data)

#MAKING PLOT 1 (PROPHAGE COUNTS)

library(ggplot2)

p1 <- ggplot(
  prophage_plot_data,
  aes(x = Genome, y = Prophage_Count)
) +
  geom_col(fill = "#218C74", width = 0.65) +
  geom_text(
    aes(label = Prophage_Count),
    vjust = -0.5,
    size = 5
  ) +
  scale_y_continuous(
    breaks = seq(0, 14, 2),
    limits = c(0, 16),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Predicted Prophage Regions Across Four E. coli Genomes",
    x = "E. coli genome",
    y = "Number of predicted prophage regions"
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold", hjust = 0.5, size = 14
    ),
    axis.text.x = element_text(
      angle = 20, hjust = 1, colour = "black"
    )
  )

# Display the plot
print(p1)

# Save publication-quality files
ggsave(
  "CODE/R Scripts/plots/plot1_prophage_counts.png",
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  "CODE/R Scripts/plots/plot1_prophage_counts.pdf",
  plot = p1,
  width = 10,
  height = 6,
  bg = "white"
)


# Plot 2: Total predicted prophage length by genome

library(ggplot2)

# Convert base pairs to kilobase pairs
prophage_plot_data$Total_Length_kbp <-
  prophage_plot_data$Total_Length_bp / 1000

# Create the plot
p2 <- ggplot(
  prophage_plot_data,
  aes(
    x = Genome,
    y = Total_Length_kbp
  )
) +
  geom_col(
    fill = "#2878B5",
    width = 0.65
  ) +
  geom_text(
    aes(label = sprintf("%.1f", Total_Length_kbp)),
    vjust = -0.5,
    size = 4.5
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title = "Total Predicted Prophage Length Across Four E. coli Genomes",
    x = "E. coli genome",
    y = "Total predicted prophage length (kbp)"
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      hjust = 0.5
    ),
    axis.text.x = element_text(
      angle = 20,
      hjust = 1,
      colour = "black"
    )
  )

# Display plot
print(p2)

# Save PNG and PDF
ggsave(
  "CODE/R Scripts/plots/plot2_total_prophage_length.png",
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  "CODE/R Scripts/plots/plot2_total_prophage_length.pdf",
  plot = p2,
  width = 10,
  height = 6,
  bg = "white"
)



# PLOT 3: Distribution of prophage lengths by genome

library(ggplot2)

prophages <- read.delim(
  "prophage_regions.tsv",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE
)

prophages$Genome <- factor(
  prophages$genome,
  levels = c("K-12 MG1655", "CFT073", "O157:H7 Sakai", "UTI89")
)

p3 <- ggplot(
  prophages,
  aes(x = Genome, y = length_bp, fill = Genome)
) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.75,
    outlier.shape = NA,
    colour = "grey25"
  ) +
  geom_jitter(
    width = 0.12,
    size = 2.2,
    alpha = 0.8,
    colour = "#263238"
  ) +
  scale_y_log10(
    labels = scales::label_comma()
  ) +
  scale_fill_manual(values = c(
    "#218C74", "#2878B5", "#D98E32", "#8267A8"
  )) +
  labs(
    title = "Distribution of Predicted Prophage Lengths",
    subtitle = "Individual regions shown as points; length axis uses a log10 scale",
    x = "E. coli genome",
    y = "Prophage length (bp, log10 scale)"
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, colour = "grey35"),
    axis.text.x = element_text(
      angle = 20, hjust = 1, colour = "black"
    ),
    legend.position = "none"
  )

print(p3)

ggsave(
  "CODE/R Scripts/plots/plot3_prophage_length_boxplot.png",
  p3, width = 10, height = 6.5, dpi = 300, bg = "white"
)

ggsave(
  "CODE/R Scripts/plots/plot3_prophage_length_boxplot.pdf",
  p3, width = 10, height = 6.5, bg = "white"
)


# PLOT 4: Standardized heatmap of prophage characteristics

library(ggplot2)
library(tidyr)

heatmap_data <- prophage_plot_data[, c(
  "Genome",
  "Prophage_Count",
  "Total_Length_bp",
  "Mean_Length_bp",
  "Transposable_Count"
)]

# Standardize each measure using z-scores
heatmap_matrix <- scale(
  as.matrix(heatmap_data[, -1])
)

heatmap_long <- data.frame(
  Genome = heatmap_data$Genome,
  heatmap_matrix,
  check.names = FALSE
)

heatmap_long <- pivot_longer(
  heatmap_long,
  cols = -Genome,
  names_to = "Measure",
  values_to = "Z_score"
)

# More readable labels
heatmap_long$Measure <- factor(
  heatmap_long$Measure,
  levels = c(
    "Prophage_Count",
    "Total_Length_bp",
    "Mean_Length_bp",
    "Transposable_Count"
  ),
  labels = c(
    "Prophage count",
    "Total length",
    "Mean length",
    "Transposable regions"
  )
)

p4 <- ggplot(
  heatmap_long,
  aes(x = Measure, y = Genome, fill = Z_score)
) +
  geom_tile(colour = "white", linewidth = 1.2) +
  geom_text(
    aes(label = sprintf("%+.2f", Z_score)),
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_gradient2(
    low = "#2878B5",
    mid = "white",
    high = "#C7473A",
    midpoint = 0,
    name = "Standardized\nscore"
  ) +
  labs(
    title = "Comparative Heatmap of Prophage Characteristics",
    subtitle = "Values standardized across the four E. coli genomes",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, colour = "grey35"),
    axis.text.x = element_text(
      angle = 25, hjust = 1, colour = "black"
    ),
    axis.text.y = element_text(colour = "black"),
    panel.grid = element_blank()
  )

print(p4)

ggsave(
  "CODE/R Scripts/plots/plot4_prophage_heatmap.png",
  p4, width = 10, height = 5.5, dpi = 300, bg = "white"
)

ggsave(
  "CODE/R Scripts/plots/plot4_prophage_heatmap.pdf",
  p4, width = 10, height = 5.5, bg = "white"
)


# Inspect the AMR dataset and its column names
names(amr_matches)
print(amr_matches)


# PLOT 5: Prophage regions and AMR-associated gene locations

library(ggplot2)

# Dataset 1: predicted prophage regions from TSV
prophages <- read.delim(
  "prophage_regions.tsv",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE
)

# Dataset 2: AMR-associated matches from ABRicate Excel
amr_raw <- readxl::read_excel(
  "AMR Associated gene matched_ABRicate.xlsx",
  skip = 1,
  col_names = FALSE
)

# Assign the actual seven column names
names(amr_raw) <- c(
  "Genome", "Gene", "Start", "End",
  "Identity", "Coverage", "Annotation"
)

# Remove repeated header and TOTAL rows, if present
amr_raw <- subset(
  as.data.frame(amr_raw),
  Genome %in% c(
    "K-12 MG1655", "CFT073", "O157:H7 Sakai", "UTI89"
  )
)

amr_raw$Start <- as.numeric(amr_raw$Start)
amr_raw$End <- as.numeric(amr_raw$End)

# Standardize genome labels and coordinate columns
prophages$Genome <- prophages$genome
prophages$Start <- as.numeric(prophages$begin)
prophages$End <- as.numeric(prophages$end)

genome_order <- c(
  "K-12 MG1655", "CFT073", "O157:H7 Sakai", "UTI89"
)

prophages$Genome <- factor(prophages$Genome, levels = genome_order)
amr_raw$Genome <- factor(amr_raw$Genome, levels = genome_order)

# Plot prophage intervals as horizontal segments
p5 <- ggplot() +
  geom_segment(
    data = prophages,
    aes(
      x = Start, xend = End,
      y = 1, yend = 1
    ),
    linewidth = 5,
    colour = "#218C74",
    lineend = "butt"
  ) +
  geom_point(
    data = amr_raw,
    aes(x = Start, y = 1),
    colour = "#C7473A",
    size = 3
  ) +
  facet_wrap(~ Genome, ncol = 1, scales = "free_x") +
  scale_x_continuous(labels = scales::label_comma()) +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(
    title = "Genomic Positions of Predicted Prophages and AMR Matches",
    subtitle = "Green segments: prophage regions | Red points: ABRicate AMR-associated matches",
    x = "Genome coordinate (bp)"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, colour = "grey35"),
    strip.text = element_text(face = "bold"),
    panel.spacing = grid::unit(1, "lines")
  )

print(p5)

ggsave(
  "CODE/R Scripts/plots/plot5_genomic_positions.png",
  p5, width = 11, height = 8, dpi = 300, bg = "white"
)

ggsave(
  "CODE/R Scripts/plots/plot5_genomic_positions.pdf",
  p5, width = 11, height = 8, bg = "white"
)


# PLOT 5: Numerical overlap verification

overlap_results <- data.frame()

for (i in seq_len(nrow(amr_raw))) {
  
  genome_name <- as.character(amr_raw$Genome[i])
  
  genome_prophages <- subset(
    prophages,
    as.character(Genome) == genome_name
  )
  
  overlaps <- genome_prophages[
    genome_prophages$Start <= amr_raw$End[i] &
      genome_prophages$End >= amr_raw$Start[i],
  ]
  
  overlap_results <- rbind(
    overlap_results,
    data.frame(
      Genome = genome_name,
      Gene = amr_raw$Gene[i],
      AMR_Start = amr_raw$Start[i],
      AMR_End = amr_raw$End[i],
      Overlapping_Prophage_Count = nrow(overlaps),
      Overlap_Detected = ifelse(
        nrow(overlaps) > 0, "Yes", "No"
      )
    )
  )
}

print(overlap_results)

write.csv(
  overlap_results,
  "CODE/R Scripts/plots/plot5_overlap_verification.csv",
  row.names = FALSE
)

