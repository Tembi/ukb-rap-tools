## STEP 1: PREP RVTESTSINPUT FILES IN R (#https://zhanxw.github.io/rvtests/#phenotype-file)
#phenotype file should be in plink format (fam/ped),name by date e.g  pheno_rvt_20250801.txt
#covariate file (includes PCs), name by date e.g  cov_rvt_20250801.txt
#genelist file (only gene symbols) e.g genelist_rvt_20250801.txt
#download the refFlat38 zip file, unzip and upload to working directory

## STEP 2: UPLOAD THE INPUT FILEs TO THE RAP
#for example dx cd to /Epilepsy/test_import/ #from this point
#dx upload -r ${input_dir}