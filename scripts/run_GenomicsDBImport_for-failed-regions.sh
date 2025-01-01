#!/usr/bin/bash

#Declare variables for SRR IDs
#SampleNames=(`cat <(tail -n +2 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv | awk -F "\t" 'BEGIN{OFS="\t"}{print $6}') <(tail -n +2 metafiles/DRP005544_SraRunTable_v2.txt | awk '{print $1}')`)
SampleNames=(
sample1
sample2
sample3
sample4
sample5
)

#GVCF path
gvcf_path="/path_to_gatk"
#CPU usage
thread=45
#Path to reference genome fasta
Genome_GATK_path="/path_to_fasta/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"

#Delare INTERVALS variable
INTERVALS=(`cat intervals.list`)

#Generate options for GenomicsDBImport
gvcf_files=""
for i in `seq 0 $((${#SampleNames[@]}-1))`; do
gvcf_files=${gvcf_files}"-V ${gvcf_path}/${SampleNames[${i}]}.g.vcf.gz "
done

#Declare failed samples
FAILED=(`cat FAILED.txt`)

#Perform GenomicsDBImport
echo "${FAILED[@]} " | xargs --delimiter=" " -P ${thread} -I {} sh -c "gatk --java-options "-Xmx40g" GenomicsDBImport -R ${Genome_GATK_path} ${gvcf_files} -L {}.list --genomicsdb-workspace-path {}_db 2>{}.GenomicsDBImport.err.log 1>{}.GenomicsDBImport.out.log"
