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
