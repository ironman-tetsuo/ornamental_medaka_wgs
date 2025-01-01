# PCA analysis

PCA can be performed from the PLINK BED/BIM/FAM files using PLINK.
```
plink \
--allow-extra-chr \
--bfile merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--out merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--pca 50
```
