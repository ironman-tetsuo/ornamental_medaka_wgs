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
gvcf_path="/path_to_gvcf"
#CPU usage
thread=20
#path to the indexed reference genome fasta
Genome_GATK_path="/path_to_reference_genome/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"

#Declare INTERVAL variable
INTERVALS=(`cat intervals.list`)

#Generate options for GenomicsDBImport
gvcf_files=""
for i in `seq 0 $((${#SampleNames[@]}-1))`; do
gvcf_files=${gvcf_files}"-V ${gvcf_path}/${SampleNames[${i}]}.g.vcf "
done

#Perform GenotypeGVCFs
seq 0 $((${#INTERVALS[@]}-1)) | tr "\n" " " | xargs --delimiter=" " -P ${thread} -I {} sh -c "gatk --java-options "-Xmx10g" GenotypeGVCFs -R ${Genome_GATK_path} -genomicsdb-use-vcf-codec -V gendb://{}_db -O {}.vcf 2>{}.GenotypeGVCFs.err.log 1>{}.GenotypeGVCFs.out.log"
