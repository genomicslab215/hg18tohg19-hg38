#!/bin/bash

# Download database and script
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg19.over.chain.gz
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
wget https://raw.githubusercontent.com/Shicheng-Guo/GscPythonUtility/master/liftOverPlink.py
wget https://raw.githubusercontent.com/Shicheng-Guo/Gscutility/master/ibdqc.pl

# Make liftOver executable
chmod +x liftOver

# Rebuild plink file to avoid chromosome-miss-order problem
plink --bfile example --make-bed --out example_sorted

# Convert space to tab to generate bed files for liftOver from hg18 to hg19
plink --bfile example_sorted --recode tab --out example_tab

# Apply liftOverPlink.py to update hg18 to hg19 or hg38
mkdir liftOver
python3 liftOverPlink.py -m example_tab.map -p example_tab.ped -o example_hg19 -c hg18ToHg19.over.chain.gz -e ./liftOver

# Convert from hg19 to hg38 using CrossMap
plink --bfile Cohort_b37 --keep-allele-order --recode vcf --out Cohort_b37_vcf
CrossMap vcf --chromid l ./hg19ToHg38.over.chain.gz Cohort_b37_vcf.vcf $referenceFasta_b38 Cohort_b38_vcf.vcf
plink --vcf Cohort_b38_vcf.vcf --make-bed --out Cohort_b38



echo "Genome conversion and renaming completed."
