library(ieugwasr)
library(dplyr)
library(reshape2)
library(mrScan)

id.list <- read.csv(snakemake@input[["id_list"]])$id
df_info <- read.csv(snakemake@input[["trait_info"]])
R2_cutoff <- as.numeric(snakemake@params[["R2_cutoff"]])
method <- snakemake@params[["method"]]
res_cor <- readRDS(snakemake@input[["pairwise_cor"]])
extra_traits <- snakemake@params[["extra_traits"]]
cluster_selection_method <- snakemake@params[["cluster_selection_method"]]
df_bidirection <- read.csv(snakemake@input[["df_bidirection"]])
out_id_list <- snakemake@output[["out_id_list"]]
out_trait_info <- snakemake@output[["out_trait_info"]]

Rg <- abs(res_cor$Rg)
df_pairs <- melt(Rg, value.name = "cor",varnames = c("id1","id2")) %>%
  filter(cor != 1)
df_matrix <- data.frame(Rg,check.names = FALSE)
res_unique <- unique_traits(id.list = id.list, df_info = df_info, R_matrix = df_matrix,
                            df_pairs = df_pairs, R2_cutoff = R2_cutoff, method = method,
                            cluster_selection_method = cluster_selection_method,
                            extra_traits = extra_traits, df_bidirection = df_bidirection)
write.csv(data.frame(id = res_unique$id.list),file = out_id_list,row.names = F)
write.csv(res_unique$trait.info,file = out_trait_info,row.names = F)
