#!/usr/bin/bash

#path to VCF
vcf_path="/path_to_vcf_file"
#Variables
COLUMN=(`awk '{print $1}'  column_phenotype.txt`)
PHENOTYPE=(`awk '{print $2}'  column_phenotype.txt`)

#Parameters for variant filtering
MISSING=0.70
MAF=0.05

for k in `seq 0 $((${#COLUMN[@]}-1))`; do
tail -n +2 ${PHENOTYPE[${k}]}.assoc.adjusted | awk '{print $2,$1,$3}' | sort -k1f > tmp1
grep -v "^#" ${vcf_path}/merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.with-ID.vcf | awk '{print $3, $2}' | sort -k1f >  SNP-BP.txt
join -1 1 -2 1 tmp1 SNP-BP.txt | awk 'BEGIN {OFS="\t"}{print $1,$2,$4,$3}' | sort -k1,1f > ${PHENOTYPE[${k}]}.gwas
done
