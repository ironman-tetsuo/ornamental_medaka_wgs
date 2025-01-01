#!/usr/bin/bash
#Path to fasta
Genome_GATK_path="/path_to_reference/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"
#SNP
gatk SelectVariants -R ${Genome_GATK_path} -V merged.vcf --select-type-to-include SNP -O merged_SNP.vcf
#INDEL
gatk SelectVariants -R ${Genome_GATK_path} -V merged.vcf --select-type-to-include INDEL -O merged_INDEL.vcf
#SNP and INDEL
gatk SelectVariants -R ${Genome_GATK_path} -V merged.vcf --select-type-to-include SNP --select-type-to-include INDEL -O merged_SNP_INDEL.vcf

#Count number of rows
paste -d "\t" \
<(grep -v "^#" merged_SNP.vcf | wc -l) \
<(grep -v "^#" merged_INDEL.vcf | wc -l) \
<(grep -v "^#" merged_SNP_INDEL.vcf | wc -l) \
> Stats_SNP_INDEL_SNP-INDEL.txt
