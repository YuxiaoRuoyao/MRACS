
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrScan

This is the R package for mrScan (Automatically Select Heritable
Confounders for Mendelian Randomization). This package will help you to
find phenome-wide potential heritable confounders and give direct causal
estimates of the main exposure to the outcome after adjusting for
confounders by multivariable Mendelian Randomization (MVMR).

## Installation with vignettes

You can install the development version of mrScan from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("YuxiaoRuoyao/mrScan",build_vignettes = TRUE)
browseVignettes("mrScan")
```

You should also install the following packages in advance for vignette:

``` r
install.packages("dplyr")
install.packages("remotes")
install.packages("stringr")
remotes::install_github("MRCIEU/TwoSampleMR")
devtools::install_github("mrcieu/ieugwasr")
devtools::install_github("noahlorinczcomi/MRBEE")
devtools::install_github("jean997/GFA")
devtools::install_github("jingshuw/grapple")
devtools::install_github("jean997/esmr", ref = "tau_nesmr2")
devtools::install_github("osorensen/hdme", build_vignettes = TRUE)
```

Please note the vignette only provides a simple example of function
usage. If you want to do a systematically searching for heritable
confounders and accurately get the causal estimate of the main exposure,
we recommend you to use the prepared Snakemake pipeline.

## Snakemake pipeline usage

### Install Snakemake

See the official install instruction
[here](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).
You can also quickly learn the usage of Snakemake
[here](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html).

### Install necessary R packages

You probably will need the following R packages if you want to use local
GWAS summary statistics.

``` r
devtools::install_github("mrcieu/gwasvcf")
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("VariantAnnotation")
install.packages("rlang")
remotes::install_github("privefl/bigsnpr")
```

### Download the Snakemake pipeline

You need to download the whole pipeline directory to your local space.
There are multiple ways to that. You can quickly use [Download
Directory](https://download-directory.github.io/). Just copy address
link
<https://github.com/YuxiaoRuoyao/mrScan/tree/master/vignettes_Snakemake_pipeline>
and download.

### Edit the config file based on your need

You may need to edit options in the `config.yaml` to fit your need. The
config file contains comments describing each option. Here are some
detailed notes you may need when choosing parameter options:

- `info_exposure_outcome`: Trait information csv file name for the main
  exposure and the outcome. It should contain the following column:

- id: Trait ID from IEU OpenGWAS database

- trait: Trait name

- sex: Gender of traits

- sample_size: sample size of the data

- population: population of the data

If you traits are from IEU OpenGWAS database, you can leave it as NA and
the pipeline will generate one by `ieugwasr::gwasinfo()`. If you want to
provide your own file, you need to change this parameter to the local
file path.

- `extract_traits`: We provide two options `IEU` or `local` for
  extracting instruments of the main exposure. If you choose `IEU`
  option, you need to make sure your exposure ID is exactly matched the
  GWAS trait ID in IEU GWAS database. If you choose `local` option, you
  need to provide the local file path of the data.

Similarly, you still have either `IEU` or `local` when selecting
candidate traits. You may need to change the trait batch when choosing
`IEU` option. (Here is the [batch
description](https://gwas.mrcieu.ac.uk/datasets/)) If you already have a
list of candidate confounders list and have downloaded their GWAS
summary statistics, you need to create a candidate traits info
dataframe. Check the optional step below for detailed instruction.

- `ldprune`: When you do LD clumping on local data, you need to download
  the LD reference files
  [here](http://fileserve.mrcieu.ac.uk/ld/1kg.v3.tgz). And then change
  `ref_path` to your own directory.

- `estimate_R`: When you use LDSC to estimate pairwise genetic
  correlation or sample overlap between traits, you need to download the
  reference LD score files [here](https://zenodo.org/records/8182036).
  Run the following command to uncompress the file:

``` r
tar xvzf eur_w_ld_chr.tar.gz
```

Remember to change `l2_dir` option to your local path.

### (Optional Step) Create a csv file with all candidate traits if you want to use local data

If you have a list of potential candidate traits and have already
downloaded GWAS summary data to local, you need to create a csv file
containing the file information of local data. And then change the
`df_candidate_traits` option to your file name in the `config.yaml`.

The GWAS data itself can be in one of three formats:

- A vcf file downloaded from the IEU Open GWAS database
- A harmonized .h.tsv.gz file downloaded from EBI database
- A flat file with columns for snp, effect and non-effect alleles,
  effect estimate, and standard error

The csv file should contain the following columns and use NA to indicate
missing data:

- trait_ID: The GWAS trait ID for this specific study. Basically just
  use the trait ID in the IEU database.
- path: Local path to the raw data files.  
- snp: Column name for rsid.  
- beta_hat: Column name for coefficient estimate.
- se: Column name for standard error of beta_hat.
- p_value: Column name for p-value.

Note that we recommend you just make `p_value = NA` in case sometimes
the provided p-value of the data is not correct. If the local files are
downloaded from IEU Open GWAS database or EBI database (harmonized one),
you can just write NA for `snp`, `beta_hat`, `se` and `p_value` column
and don’t need to check the exact column name. But you must need to
provide `snp`, `beta_hat` and `se` column names if it’s a flat file
because we don’t know your own data structure in advance.

We have prepared an example info file named `example_candidate_info.csv`
for your reference.

### Run the pipeline

We recommend to run the Snakemake pipeline on a cluster since it may
create hundreds of jobs. If you run it on the cluster, you may need to
edit the `run-snakemake.sh` script to match your cluster structure.
Also, you can edit the `cluster.yaml` to change the memory or time usage
for each step.

To run the pipeline:

``` r
bash run-snakemake.sh
```

You may want to dry run the pipeline first to see what will be done:

``` r
snakemake -np
```

Please note that if you use default data setting, this pipeline will
search traits and extract instruments based on IEU OpenGWAS database by
API. It could cause error when the server is experiencing traffic or the
internet is not stable. If some jobs fail due to this problem, just
rerun the pipeline after some time.

### Check the result

All results will be in a folder in your directory called `results/`
unless you changed the `output_dir` option in `config.yaml`. And `data/`
directory will save all the data used or generated in the intermediate
steps. The `log/` directory contains the error or output log for each
job. You can check error reasons in this folder.

We recommend you to check the selected traits for each step and you can
manually delete or add some traits based on your own needs and
understanding. Ensure to rerun the pipeline after changing the
intermediate results, Snakemake will help you to only rerun the steps
that are affected by the change in the intermediate results.
