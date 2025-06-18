library(pheatmap)
library(ape)
library(ggtree)
library(treeio)
library(readr)
library(tidyverse)
library(ComplexHeatmap)
library(circlize)
library(stringr)
library(magrittr)
library(patchwork)
library(viridis)
library(cowplot)
library(regions)

setwd("~/MartynasLib/Universitetas/3 kursas/6 semestras/kursinis")

df <- read_csv("gene_presence_absence.csv") %>%
  pivot_longer(
    cols = -c(Gene, `Non-unique Gene name`, Annotation),
    names_to = "strain",
    values_to = "prokka_id"
  ) %>%
  filter(!is.na(prokka_id))

binary_matrix <- df %>%
  select(Gene, strain) %>%        
  mutate(presence = 1) %>%       
  pivot_wider(
    names_from = strain,
    values_from = presence,
    values_fill = 0
  )

tree <- read.tree("core_gene_alignment.aln.treefile")
tree$tip.label <- sub("(\\.1).*", "\\1", tree$tip.label)
tree <- root(tree, outgroup = "GCF_003253775.1", resolve.root = TRUE)
tree$edge.length <- log1p(tree$edge.length)

metadata <- read_tsv("metadata.tsv") %>%
  rename(biosample = BioSample) %>%
  mutate(across(everything(), ~na_if(trimws(.), "not provided"))) %>%
  mutate(across(everything(), ~na_if(., "null"))) %>%
  mutate(across(everything(), ~na_if(., "Unknown"))) %>%
  mutate(across(everything(), ~na_if(., "not applicable"))) %>%
  mutate(across(everything(), ~na_if(., "missing"))) %>%
  mutate(across(everything(), ~na_if(., "not collected"))) %>%
  mutate(across(everything(), ~na_if(., "Not determined"))) %>%
  mutate(
    country_group = str_trim(str_extract(geo_loc_name, "^[^:]+")),
    sample = case_when(
      str_detect(tolower(isolation_source), "sputum") ~ "Sputum",
      str_detect(tolower(isolation_source), "lymph node") ~ "Lymph node",
      TRUE ~ "Other"
    ),
    host_fix = case_when(
      str_detect(tolower(host), "homo sapiens") ~ "Homo sapiens",
      TRUE ~ host
    )
  ) %>%
  mutate(
    region_group = case_when(
      country_group %in% c(
        "Belgium", "Bulgaria", "Belarus", "Denmark", "France", 
        "Germany", "Ireland", "Poland", "Russia"
      ) ~ "Europe",
      
      country_group %in% c(
        "India", "China", "Japan", "Thailand", "Philippines", "Viet Nam", "Afghanistan"
      ) ~ "Asia",
      
      country_group %in% c(
        "Cameroon", "Cote d'Ivoire", "Burundi", "Ethiopia", "Gambia",
        "Ghana", "Republic of the Congo", "Rwanda", "Sierra Leone"
      ) ~ "Africa",
      
      country_group %in% c("Canada", "USA") ~ "North America",

      TRUE ~ "Other"
    )
  )

datasum <- read_tsv("data_summary.tsv") %>%
  rename(assembly = `Assembly Accession`, biosample = BioSample) %>%
  select(-c(1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14))

gene_classes <- df %>%
  count(Gene, name = "n_genomes") %>%
  mutate(class = case_when(
    n_genomes / 87 > 0.99 ~ "core",
    n_genomes / 87 > 0.95 ~ "soft_core",
    n_genomes / 87 > 0.15 ~ "shell",
    TRUE ~ "cloud"
  ))

strain_accessory_counts <- df %>%
  left_join(gene_classes, by = "Gene") %>%
  filter(class %in% c("cloud", "shell")) %>%
  count(strain, class) %>%
  pivot_wider(names_from = class, values_from = n, values_fill = 0) %>%
  mutate(accessory = cloud + shell) %>%
  mutate(strain = sub("(\\.1).*", "\\1", strain)) %>%
  filter(strain != "GCF_003253775.1")

trunk_genome <- tibble(
#  strain = "GCF_003253775.1",
  biosample = "SAMN09104579"
)

#tree_df <- bind_rows(tree_df, trunk_genome)

#metadata <- bind_rows(metadata, trunk_genome)

p_tree <- ggtree(tree)

tip_order <- p_tree$data %>%
  filter(isTip) %>%
  arrange(y) %>%
  pull(label)

tree_df <- data.frame(strain = tree$tip.label) %>%
  left_join(datasum, by = c("strain" = "assembly")) %>%
  left_join(strain_accessory_counts, by = c("strain" = "strain")) %>%
  left_join(metadata, by = "biosample") %>%
  filter(!is.na(biosample))

tree_df <- tree_df %>%
  filter(strain.x %in% tip_order) %>%
  mutate(strain = factor(strain.x, levels = rev(tip_order))) %>%
  arrange(strain)


#tree_df <- tree_df %>%
  #mutate(strain.x = factor(strain.x, levels = tree$tip.label)) %>%
  #arrange(strain.x)

#setdiff(tree$tip.label, tree_df$strain)

#tree$edge.length <- log1p(tree$edge.length)


#----------------------------------------------------------
# Lentele kursiniam darbui apie genomu info

#selected_df <- tree_df[, c("strain.x", "biosample", "geo_loc_name", "collection_date")]
#selected_df <- selected_df%>%
  #mutate(country_clean = str_remove_all(geo_loc_name, ":.*|,.*") %>% str_trim())
#selected_df$collection_date <- substr(selected_df$collection_date, 1, 4)
#write.csv(selected_df, file = "atrinkti_genomai.csv", row.names = FALSE)


#--------------------------------------------------------------AMR
amr_raw <- read_tsv("all_amr.tsv")

genes_to_mark <- c(
  "aminoglycoside N-acetyltransferase AAC(2')-Ic",
  "23S rRNA (adenine(2058)-N(6))-methyltransferase Erm(37)",
  "class A beta-lactamase BlaC",
  "aminoglycoside O-phosphotransferase APH(3')-Ia"
)

df <- df %>%
  mutate(prokka_prefix = str_extract(prokka_id, "^[^_]+"))

prefix_to_strain <- df %>%
  distinct(prokka_prefix, strain) %>%
  mutate(strain = sub("(\\.1).*", "\\1", strain))

amr_data <- amr_raw %>%
  mutate(prokka_prefix = str_extract(`Protein id`, "^[^_]+"),
         Gene = `Element name`) %>%
  left_join(prefix_to_strain, by = "prokka_prefix") %>%
  mutate(strain = sub("(\\.1).*", "\\1", strain)) %>%
  filter(Gene %in% genes_to_mark)

amr_heatmap_df <- amr_heatmap_df %>%
  mutate(strain = factor(strain, levels = tree$tip.label)) %>%
  replace(is.na(.), 0) %>%
  arrange(strain)

gene_name_short <- c(
  "aminoglycoside N-acetyltransferase AAC(2')-Ic" = "AAC(2')-Ic",
  "23S rRNA (adenine(2058)-N(6))-methyltransferase Erm(37)" = "Erm(37)",
  "class A beta-lactamase BlaC" = "BlaC",
  "aminoglycoside O-phosphotransferase APH(3')-Ia" = "APH(3')-Ia"
)

amr_long <- amr_data %>%
  distinct(strain, Gene) %>%
  filter(strain %in% tip_order) %>%
  mutate(presence = 1) %>%
  complete(strain = tip_order, Gene = genes_to_mark, fill = list(presence = 0)) %>%
  mutate(
    gene = gene_name_short[Gene],
    strain = factor(strain, levels = rev(tip_order)),
    y = as.integer(strain)
  ) %>%
  arrange(strain)


#---------------------------------------------------------tree plot

#
# Atsiprasau, norejau amr padaryti ne heatmap principu, o su figuromis, 
# bet nepavyko ju graziai isdelioti. Taip pat nespejau issiaiskinti
# kaip veikia ju isdeliojimas, kad nesigadintu medis.
#

plot_tree <- function(tree, metadata_df) {
  tree_plot <- ggtree(tree) +
    geom_tiplab(size = 2, align = TRUE, linesize = 0.2) +
    #geom_treescale(x = 0, y = 1, width = 0.02) +
    #xlim(0, 30) +
    theme_tree2() + 
    #coord_cartesian(clip = 'off') +
    #coord_cartesian(xlim = c(0, 0.0015)) +
    scale_x_continuous(trans = "sqrt")
    
    #scale_x_ggtree()
  
  plot_amr_heatmap_column <- function() {
    ggplot(amr_long, aes(x = gene, y = y, fill = factor(presence))) +
      geom_tile(color = "black", height = 1) +
      scale_y_reverse(expand = c(0, 0)) +
      scale_fill_manual(values = c("0" = "white", "1" = "#8da0cb")) +
      coord_fixed(xlim = c(0.5, length(unique(amr_long$gene)) + 0.5)) +
      theme_void() +
      theme(
        axis.text.x = element_text(angle = 270, hjust = 1, vjust = 0.5),
        legend.position = "right"
      ) +
      labs(fill = "Presence", x = NULL, y = NULL)
  }
  
  plot_heatmap_column <- function(column_name, title = NULL) {
    #df <- metadata_df %>%
     # select(strain = strain.x, value = all_of(column_name)) %>%
      #filter(strain %in% tree$tip.label) %>%
      #mutate(strain = factor(strain, levels = tree$tip.label)) %>%
      #arrange(strain) %>%
      #mutate(y = row_number())
    
    #df <- metadata_df %>%
     # select(strain = strain.x, value = all_of(column_name)) %>%
      #filter(strain %in% tree$tip.label) %>%
      #mutate(strain = factor(strain, levels = tree$tip.label)) %>%
      #arrange(strain) %>%
      #mutate(y = seq_along(strain))
    
    df <- metadata_df %>%
      select(strain, value = all_of(column_name)) %>%
      mutate(y = row_number())
    
    fill_scale <- if (is.numeric(df$value)) {
      scale_fill_distiller(palette = "YlGnBu", direction = 1, na.value = "white")
    } else {
      scale_fill_brewer(palette = "Set2", na.value = "white")
    }
    
    ggplot(df, aes(x = 1, y = y, fill = value)) +
      geom_tile(color = "black", height = 1) +
      scale_y_reverse(expand = c(0, 0)) +
      fill_scale +
      coord_fixed(xlim = c(0, 2)) +
      theme_void() +
      theme(
        legend.position = "right",
        axis.text.x = element_text(angle = 270, hjust = 1.5, vjust = 0.5),
        axis.title.x = element_text(margin = margin(t = 10))
      ) +
      scale_x_continuous(breaks = 1, labels = title) +
      labs(fill = title, x = NULL)
  }
  
  
  hm_region <- plot_heatmap_column("region_group", "Region")
  hm_host      <- plot_heatmap_column("host_fix", "Host")
  hm_sample    <- plot_heatmap_column("sample", "Sample Type")
  hm_cloud     <- plot_heatmap_column("cloud", "Cloud Genes")
  hm_shell     <- plot_heatmap_column("shell", "Shell Genes")
  hm_accessory <- plot_heatmap_column("accessory", "Accessory Genes")
  #hm_erm37 <- plot_amr_heatmap(amr_matrix, "erm(37)", "erm(37)")
  
  final_plot <- (
    tree_plot |
      hm_region  |
      hm_host    |
      hm_sample  |
      hm_cloud   |
      hm_shell   |
      hm_accessory |
      #plot_spacer() |
      plot_amr_heatmap_column()
  ) +
    plot_layout(
      guides = "collect",
      #widths = c(3, 0.2, 0.2, 0.2, 0.2, 0.3, 0.3, 0.05, 1)
    )
  
  return(final_plot)
}

#widths = c(3, 0.5, 0.5, 0.5, 0.5, 0.2, 0.2)

ggsave("tree_new.png", plot = plot_tree(tree, tree_df), width = 20, height = 15, dpi = 300)


#ggtree(tree) + geom_tiplab(size = 2)

#setdiff(tree$tip.label, tree_df$strain.x)
#setdiff(tree_df$strain.x, tree$tip.label)
#head(tree$tip.label)
#head(tree_df$strain.x)

setdiff(tip_order, amr_heatmap_df$strain)
