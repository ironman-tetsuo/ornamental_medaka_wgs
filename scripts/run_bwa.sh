#!/bin/bash
#SampleNames=(`tail -n +2 metafiles/210209_Medaka_v1.txt | awk -F "\t" 'BEGIN{OFS="\t"}{print $2}'  | xargs`)
SampleNames=(
sample1
sample2
sample3
sample4
)

fastq_path="/path_to_trimmed_fastq"
thread=3
GenomeFile="/path_to_genome_indexed_fasta/Oryzias_latipes.ASM223467v1.dna_sm.toplevel"

for i in `seq 0 $((${#SampleNames[@]}-1))`; do
MyRG="@RG\tID:"${SampleNames[${i}]}"\tPL:ILLUMINA\tSM:"${SampleNames[${i}]}
bwa mem ${GenomeFile} \
-R ${MyRG} \
${fastq_path}/${SampleNames[${i}]}_1.paired.fastq.gz \
${fastq_path}/${SampleNames[${i}]}_2.paired.fastq.gz \
-t ${thread} \
| samtools view -@ ${thread} -h -bS | samtools sort -@ ${thread} > ${SampleNames[${i}]}.sort.bam
samtools index ${SampleNames[${i}]}.sort.bam
done
