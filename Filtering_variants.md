# Filtering variants

The concatenated vcf file is subjected to variant filtering to extract SNPs and INDELs.
- [run_filtering.sh](scripts/run_filtering.sh)
```
#!/usr/bin/bash
#Path to the indexed reference genome
Genome_GATK_path="/path_to_reference_fasta/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"
#Variant filtering based on MAF and genotyping rate
MISSING=0.90
MAF=0.05
vcftools --max-missing ${MISSING} --maf ${MAF} --vcf merged_SNP_INDEL.vcf --recode --recode-INFO-all  --stdout >  merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.vcf

#Indexing the vcf file
gatk --java-options "-Xmx40g" IndexFeatureFile -I merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.vcf

#SNP
gatk SelectVariants -R ${Genome_GATK_path} \
-V merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.vcf \
--select-type-to-include SNP \
-O merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}_SNP.vcf

#INDEL
gatk SelectVariants -R ${Genome_GATK_path} \
-V merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.vcf \
--select-type-to-include INDEL \
-O merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}_INDEL.vcf

#Count number of rows
paste -d "\t" \
<(grep -v "^#" merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}_SNP.vcf | wc -l) \
<(grep -v "^#" merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}_INDEL.vcf | wc -l) \
<(grep -v "^#" merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.vcf | wc -l) \
> Stats_SNP_INDEL_SNP-INDEL_merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.txt
```
