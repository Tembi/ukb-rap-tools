#!/bin/bash

# This script runs rvtest on the output of script 1 (QC-passed WES vcf files) 
# It uses the QC-ed WES vcf files along with a set of GRCh38 GENE reference
# files (available in this repo) and pre-made pheotype and covariate files (made prior). 
#
# You must upload the refFlat*.gz files to the UKB-RAP prior to running this script.
# I uploaded them to a subfolder of my {txt_file_dir} names reflat38.
# 
# You may run this on a pre-defined genelist using the {genelist} variable.
# if you have no genes for a chromosome, it will error out, but this will not affect the results.
#
# It is possible to run this rarevariant test genome wide, BUT this may take a very long time
# resulting in an expensive move to normal instances. I have also found a runtime bug on chr2.
# If you must run genome wide, you should split out the refflat files into <200 gene sets.
# but that is beyond the scope of this tutorial.
 

# How to Run:
# Run this shell script using: 
#   sh ./02-wes38-rv-test.sh
# on the command line on your own machine

# Inputs:
# Note that you can adjust the output directory by setting the data_file_dir variable
# - /{txt_file_dir}/phenotypes.rvt.v09-09-22.txt - 
# - /{txt_file_dir}/covaraites.rvt.v09-09-22.txt - 
# For each chromosome you will use:
# - /{data_file_dir}/WES_c${i}_qc_pass.vcf.gz
# - /{data_file_dir}/WES_c${i}_qc_pass.vcf.gz.idx
# - /{data_file_dir}/reflat38/refFlat_c${i}.txt.gz

# for each chromosome, you will run a separate worker


# Outputs (for each chromosome $i):
# - /{data_file_dir}/{phenotype}_c${i}_rvtest.SkatO.assoc
# - /{data_file_dir}/{phenotype}_c${i}_rvtest.CMC.assoc
# - /{data_file_dir}/{phenotype}_c${i}_rvtest.Skat.assoc
# - /{data_file_dir}/{phenotype}_c${i}_rvtest.log

# Steps:
# 1. for each chromosome 1-22 and X:
# 	- download and install rvtests
#	- perform burden and skat tests for a gene panel {genelist}
# 	- remove unneeded files
#       - write out files back to RAP

#set this to the exome sequence directory that you want (should contain PLINK formatted files)
exome_file_dir="/Bulk/Exome sequences/Population level exome OQFE variants, PLINK format - final release/"
#set this to the exome data field for your release
data_field="ukb23158"
data_file_dir="/Epilepsy/test_output/" #output folder, rename this for main analysis
txt_file_dir="/Epilepsy/test_import/" #input folder, created in prep step
pheno_file="${txt_file_dir}/pheno_rvt_20250801.txt" #pheno file
gene_file="${txt_file_dir}/genelist_rvt_20250801.txt" #gene list
cov_file="${txt_file_dir}/cov_rvt_20250801.txt" #cov file

# set $genelist to a list of genes for this rarevariant test,  otherwise leave it blank for all genes
#genelist=" "
#genelist="--gene ABCG5,ABCG8,APOE,CASR,CEL,CFTR,CLDN2,CMIP,CPA1,CTRC,GGT1,PRSS1,PRSS2,PRSS3,SBDS,SLC26A9,SPINK1,UBR1,CPA1,TRB,TRPV6,RIPPLY1,TYW1,LINC01251-PRSS3"
 
# read in gene set for disease
genelist="--gene $(grep -E '^[A-Za-z0-9]+$' ${gene_file} | tr '[:lower:]' '[:upper:]' | paste -sd, -)"

# loop over all genes

for i in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,19,20,22,X}; do

    run_rvtest_wes="wget https://github.com/zhanxw/rvtests/releases/download/v2.1.0/rvtests_linux64.tar.gz; \
      tar zxvf rvtests_linux64.tar.gz;  \
      ./executable/rvtest --inVcf WES_c${i}_qc_pass.vcf.gz --freqUpper 0.05 \
      --pheno ${pheno_file} --pheno-name status --out out_c${i}_rvtest_gs5 \
      --covar ${cov_file} --covar-name age,sex,pc1,pc2,pc3,pc4 \
      --geneFile refFlat_c${i}.txt.gz ${genelist} --burden cmc --kernel skat,skato ; \
      rm rvtests_linux64.tar.gz; rm -rf ex*; rm -rf READM* "
    
    dx run swiss-army-knife -iin="${data_file_dir}/WES_c${i}_qc_pass.vcf.gz" \
     -iin="${data_file_dir}/WES_c${i}_qc_pass.vcf.gz.tbi" \
     -iin="${txt_file_dir}/${pheno_file}" \
     -iin="${txt_file_dir}/${cov_file}" \
     -iin="${txt_file_dir}/reflat38/refFlat_c${i}.txt.gz" \
     -icmd="${run_rvtest_wes}" --tag="Step2-rvt" --instance-type "mem1_ssd1_v2_x16"\
     --destination="${data_file_dir}" --brief --yes

done
