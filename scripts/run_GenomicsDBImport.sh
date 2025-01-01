#!/usr/bin/bash

#Declare variables for SRR IDs
#SampleNames=(`cat <(tail -n +2 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv | awk -F "\t" 'BEGIN{OFS="\t"}{print $6}')`)
SampleNames=(
sample1
sample2
sample3
sample4
sample5
)

#GVCF path
gvcf_path="/path_to_HaplotypeCaller"
#CPU usage
thread=20

#path to the indexed reference genome
Genome_GATK_path="/path_to_indexed_reference_genome_fasta/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"

#Divide intervals.list for parallel processing and store it in variables
INTERVALS=(`cat intervals.list`)

#Generate option for GenomicsDBImport
gvcf_files=""
for i in `seq 0 $((${#SampleNames[@]}-1))`; do
gvcf_files=${gvcf_files}"-V ${gvcf_path}/${SampleNames[${i}]}.g.vcf.gz "
done

#Perform GenomicsDBImport
seq 0 $((${#INTERVALS[@]}-1)) | tr "\n" " " | xargs --delimiter=" " -P ${thread} -I {} sh -c "gatk --java-options "-Xmx10g" GenomicsDBImport -R ${Genome_GATK_path} ${gvcf_files} -L {}.list --genomicsdb-workspace-path {}_db 2>{}.GenomicsDBImport.err.log 1>{}.GenomicsDBImport.out.log"
