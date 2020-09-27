### Plot PSMs for paper ###

rm(list=ls())

library(ComplexHeatmap)
library(circlize)

n_clusters <- 6
cluster_labels <- rep(1:n_clusters, each = 50)

n_cov <- 10

load(paste0("premium/binary-outcome/experiment1_w2_ncov", n_cov, 
            "_chain1_psm_exclude_y.RData"))
psm1 <- psm
load(paste0("premium/binary-outcome/experiment1_w4_ncov", n_cov,
            "_chain1_psm_exclude_y.RData"))
psm2 <- psm
load(paste0("premium/binary-outcome/experiment1_w6_ncov", n_cov,
            "_chain1_psm_exclude_y.RData"))
psm3 <- psm
load(paste0("premium/binary-outcome/experiment1_w8_ncov", n_cov,
            "_chain1_psm_exclude_y.RData"))
psm4 <- psm

col_fun = colorRamp2(c(0, 1), c("white","#003C71")) # Dark blue
label_colors <- c("#6CACE4", # Light blue
                  "#E89CAE", # Light pink
                  "#F1BE48", # Light yellow
                  "#B7BF10", # Light green
                  "#85b09A", # Light cambridge blue
                  "#0072ce") # Core blue
names(label_colors) <- as.character(1:n_clusters)
row_annotation <- rowAnnotation(Label = as.character(cluster_labels),
                                col = list(Label = label_colors),
                                show_legend = FALSE,
                                show_annotation_name = FALSE,
                                annotation_width = unit(0.1, "cm"))

H1 <- Heatmap(psm1,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H2 <- Heatmap(psm2,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H3 <- Heatmap(psm3,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H4 <- Heatmap(psm4,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = TRUE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation,
              heatmap_legend_param = list(title = ""))

jpeg(paste0("figures/binary-outcome/heatmap-psms-", n_cov,"cov.jpg"),
     height = 5.5, width = 23, units = "cm", res = 1200)
H1 + H2 + H3 + H4
dev.off()

load(paste0("premium/binary-outcome/experiment1_w2_ncov", n_cov,
            "_chain1_psm_exclude_y_var_sel.RData"))
psm1 <- psm
load(paste0("premium/binary-outcome/experiment1_w4_ncov", n_cov,
            "_chain1_psm_exclude_y_var_sel.RData"))
psm2 <- psm
load(paste0("premium/binary-outcome/experiment1_w6_ncov", n_cov,
            "_chain1_psm_exclude_y_var_sel.RData"))
psm3 <- psm
load(paste0("premium/binary-outcome/experiment1_w8_ncov", n_cov,
            "_chain1_psm_exclude_y_var_sel.RData"))
psm4 <- psm

col_fun = colorRamp2(c(0, 1), c("white","#003C71")) # Dark blue
label_colors <- c("#6CACE4", # Light blue
                  "#E89CAE", # Light pink
                  "#F1BE48", # Light yellow
                  "#B7BF10", # Light green
                  "#85b09A", # Light cambridge blue
                  "#0072ce") # Core blue
names(label_colors) <- as.character(1:n_clusters)
row_annotation <- rowAnnotation(Label = as.character(cluster_labels),
                                col = list(Label = label_colors),
                                show_legend = FALSE,
                                show_annotation_name = FALSE,
                                annotation_width = unit(0.1, "cm"))

H1 <- Heatmap(psm1,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H2 <- Heatmap(psm2,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H3 <- Heatmap(psm3,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = FALSE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation)
H4 <- Heatmap(psm4,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,
              show_heatmap_legend = TRUE,
              show_row_names = FALSE,
              show_column_names = FALSE,
              heatmap_width = unit(5, "cm"),
              heatmap_height = unit(5, "cm"),
              right_annotation = row_annotation,
              heatmap_legend_param = list(title = ""))

jpeg(paste0("figures/binary-outcome/heatmap-psms-", n_cov, "cov_var_sel.jpg"),
     height = 5.5, width = 23, units = "cm", res = 1200)
H1 + H2 + H3 + H4
dev.off()
