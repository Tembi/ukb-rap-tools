#!/bin/bash

# This script runs the cohort and QC filter on the WES data using plink and unix tools.
# rvtests requires a bgzipped vcf file with the "chr" suffiz removed. 
# Depending on the total number of subjects in your phenotypes file, you will have to adjust
# the size of the vm, specifically the storage needed. I am using ~34,000 subjects allowing
# me to get away with using smaller vms with <1TB of ssd storage.  

# as of 11/01/2022
# mem2_ssd1_v2_x16 - 600GB ssd 0.106/hr
# mem2_ssd1_v2_x32 - 1200GB ssd 0.212/hr

### 01/08/2025 (based on 06 01 2024)
# mem2_ssd1_v2_x16 - 600GB ssd 0.1168/hr
# mem2_ssd1_v2_x32 - 1200GB ssd 0.2336/hr

# How to Run:
# Run this shell script using: 
#   sh ./01-wes38-qc-filter.sh 
# on the command line on your own machine


# Inputs:
# Note that you can adjust the output directory by setting the data_file_dir variable
# - /gwas_cohort_textfiles/phenotypes.v08-04-22.tx 

# for each chromosome, you will run a separate worker
# - /{exome_file_dir}/ukb23158_c1_b0_v1.bed 
# - /{exome_file_dir}/ukb23158_c1_b0_v1.bim 
# - /{exome_file_dir}/ukb23158_c1_b0_v1.fam 

# Outputs (for each chromosome):
# - /{data_file_dir}/WES_c1_qc_pass.vcf.gz
# - /{data_file_dir}/WES_c1_qc_pass.vcf.gz.idx
# - /{data_file_dir}/WES_c1_qc_pass.log


# Steps:
# 1. for each chromosome 1-22 and X:
# 	- filter by QC metrics and cohort
#	- remove original plink files
#	- remove "chr" prefix from the Chromosome column in the vcf
# 	- bgzip and index the new vcf file
# 	- export files back to {data_file_dir}

#set this to the exome sequence directory that you want (should contain PLINK formatted files)
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - final release"
#set this to the exome data field for your release
data_field="ukb23158"
data_file_dir="Epilepsy/test_output" #output folder, rename this for main analysis
txt_file_dir="Epilepsy/import" #input folder, created in prep step
sample_list="sample_rvt202508013.txt" #rename this based on phenotype file from prep step

# default inexpensive mem/storage balance
# TEST ON CHROMOSOME 21
chr_no="21"

run_plink_wes="plink2 --bfile ${data_field}_c${chr_no}_b0_v1\
  --no-pheno --keep ${sample_list} \
  --geno 0.1 --mind 0.1 --recode vcf-iid \
  --out WES_c${chr_no}_qc_pass;\ #don't remove the original input file
  (grep ^"#" WES_c${chr_no}_qc_pass.vcf; grep -v ^"#" WES_c${chr_no}_qc_pass.vcf | sed 's:^chr::ig' | sort -k1,1n -k2,2n) \
  | bgzip -c > WES_c${chr_no}_qc_pass.vcf.gz; tabix -f -p vcf WES_c${chr_no}_qc_pass.vcf.gz; \
  rm WES_c${chr_no}_qc_pass.vcf "

#append correct file paths here
dx run swiss-army-knife -iin="${exome_file_dir}/${data_field}_c${chr_no}_b0_v1.bed" \
  -iin="${exome_file_dir}/${data_field}_c${chr_no}_b0_v1.bim" \
  -iin="${exome_file_dir}/${data_field}_c${chr_no}_b0_v1.fam"\
  -iin="${txt_file_dir}/${sample_list}" \
  -icmd="${run_plink_wes}" --tag="S1-vcfprep" --instance-type "mem2_ssd1_v2_x16"\
  --destination="${data_file_dir}" --brief --yes




