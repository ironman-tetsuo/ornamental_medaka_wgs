# Adding @RG tag to bam files without @RG tag
If you have bam files which are already mapped the reference genome without adding @RG tag, you can add @RG tag to them with the following script.
- [samtools_addreplacerg.sh](scripts/samtools_addreplacerg.sh)
```
#!/bin/bash
#SampleNames=(`tail -n +2 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv | awk -F "\t" 'BEGIN{OFS="\t"}{print $6}'  | xargs`)
SampleNames=
(
sample1
sample2
sample3
sample4
sample5
)

bam_path="/path_to_bam_files"
thread=40

for i in `seq 0 $((${#SampleNames[@]}-1))`; do
MyRG="@RG\tID:"${SampleNames[${i}]}"\tPL:ILLUMINA\tSM:"${SampleNames[${i}]}
echo "Processing: ${SampleNames[${i}]}.sort.bam"
samtools addreplacerg -r  ${MyRG} ${bam_path}/${SampleNames[${i}]}.sort.bam -O BAM -@ ${thread} > ${SampleNames[${i}]}.sort.bam
samtools index ${SampleNames[${i}]}.sort.bam
done
```
