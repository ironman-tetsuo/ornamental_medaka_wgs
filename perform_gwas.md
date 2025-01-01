# GWAS analysis
Check the phenotype list.
```
head -n 1 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv   | tr "\t" "\n" | awk 'BEGIN{OFS="\t"}{print NR,$1}' | tail -n +9 | tr -d "\r" > column_phenotype.txt
head -n 5 column_phenotype.txt
9    yokihi2
 10    gold2
 11    white2
 12    blue
 13    orochi
```

With the following script, GWAS will be performed on the variant data set in PLINK BED/BIM/FAM format.
```
#parameters for variant calling
MISSING=0.70
MAF=0.05

#Variables
COLUMN=(`awk '{print $1}'  column_phenotype.txt`)
PHENOTYPE=(`awk '{print $2}'  column_phenotype.txt`)

#File path
ped_path="/path_to_bed_bim_fam"
#GWAS
for k in `seq 0 $((${#COLUMN[@]}-1))`; do
plink --allow-extra-chr --chr-set 24 no-xy no-mt --bfile ${ped_path}/merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.with-ID --assoc --adjust --out ${PHENOTYPE[${k}]} --pheno ${PHENOTYPE[${k}]}.txt --allow-no-sex
done
```
Generate gwas files
- [generate_gwas_files.sh](./scripts/generate_gwas_files.sh)
```
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
```

