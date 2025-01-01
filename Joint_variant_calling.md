# Joint variant calling for generating VCF files
Generate a list of intervals.   
https://gatk.broadinstitute.org/hc/en-us/articles/360035531852-Intervals-and-interval-lists
```
WINDOW=1000000
seqkit sliding \
-s ${WINDOW} \
-W ${WINDOW} \
--seq-type dna \
--greedy Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa \
| bioawk -c fastx '{print $name}' \
| awk -F "_sliding" '{print $1$2}'\
| awk -F ":" '$1!="MT"{print $0}' \
> intervals.list

#Count number of raws
wc -l intervals.list 
745 intervals.list

#Declare intervals.list variable
INTERVALS=(`cat intervals.list`)

#Generate list files
for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
echo ${INTERVALS[${i}]} > ${i}.list
done
```


Some chunks failed to process, likely due to insufficient memory, requiring identification and reprocessing of the unsuccessful ones.   
This step itself usually completes within a few hours, so it might be better in future attempts to reduce memory usage to around 10 GB and lower the parallelism to about 20.   

- [run_GenomicsDBImport.sh](scripts/run_GenomicsDBImport.sh)
```
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
gvcf_path="/path_to_gvcf_file"
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
```

Confirm that all samples have been successfully finished.
```
#Declare INTERVALs
INTERVALS=(`cat intervals.list`)

wc -l intervals.list
745 intervals.list
echo  $((${#INTERVALS[@]}-1))
744

ls -lh | grep "_db" | wc -l
745
cat *.GenomicsDBImport.out.log | grep "true" | wc -l
745
cat *.GenomicsDBImport.err.log | grep "Import completed!" | wc -l
745
```

