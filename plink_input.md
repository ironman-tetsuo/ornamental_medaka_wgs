# Generation of input files for PLINK

Genrate PLINK ped and map format files
```
plink --vcf merged_SNP_INDEL_--max-missing0.90_--maf0.05.vcf --recode --out merged_SNP_INDEL_--max-missing0.90_--maf0.05 --double-id
```

Generate PLINK bed/bim/fam files
```
plink \
--allow-extra-chr  \
--file merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--make-bed  \
--out merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--double-id
```

Since sample names are sorted during the above processes, we generates a new sample name list from the resulting fam file.
```
awk '{print $1}' \
merged_SNP_INDEL_--max-missing0.90_--maf0.05.fam \
> merged_SNP_INDEL_--max-missing0.90_--maf0.05.name
```
