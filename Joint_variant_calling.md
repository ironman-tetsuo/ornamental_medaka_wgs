# Joint variant calling for generating VCF files
## Generate the variant database for the intervals
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

Find failed sample, and redo analyses.
```
#Declare INTERVALS
INTERVALS=(`cat intervals.list`)

wc -l intervals.list
745 intervals.list
echo  $((${#INTERVALS[@]}-1))
744

ls -lh | grep "_db" | wc -l
745
cat *.GenomicsDBImport.out.log | grep "true" | wc -l
686
cat *.GenomicsDBImport.err.log | grep "Import completed!" | wc -l
686

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done  | head -n 20
1:1-1000000    0    
 1:1000001-2000000    1    
 1:2000001-3000000    2    13:12:13.195 INFO  GenomicsDBImport - Import completed!
 1:3000001-4000000    3    13:12:23.188 INFO  GenomicsDBImport - Import completed!
 1:4000001-5000000    4    13:12:23.235 INFO  GenomicsDBImport - Import completed!
 1:5000001-6000000    5    13:12:03.690 INFO  GenomicsDBImport - Import completed!
 1:6000001-7000000    6    13:11:46.418 INFO  GenomicsDBImport - Import completed!
 1:7000001-8000000    7    13:11:36.873 INFO  GenomicsDBImport - Import completed!
 1:8000001-9000000    8    13:12:03.695 INFO  GenomicsDBImport - Import completed!
 1:9000001-10000000    9    13:11:47.163 INFO  GenomicsDBImport - Import completed!
 1:10000001-11000000    10    13:11:42.815 INFO  GenomicsDBImport - Import completed!
 1:11000001-12000000    11    13:12:03.482 INFO  GenomicsDBImport - Import completed!
 1:12000001-13000000    12    
 1:13000001-14000000    13    13:12:18.984 INFO  GenomicsDBImport - Import completed!
 1:14000001-15000000    14    
 1:15000001-16000000    15    13:12:25.192 INFO  GenomicsDBImport - Import completed!
 1:16000001-17000000    16    
 1:17000001-18000000    17    
 1:18000001-19000000    18    13:12:39.530 INFO  GenomicsDBImport - Import completed!
 1:19000001-20000000    19    

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done | awk 'NF==2{print $2}' | wc -l
59 #59 + 686 = 745

#Delete failed ones
for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done | awk 'NF==2{print $2"_db"}' | xargs rm -rf 

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done | awk 'NF==2{print $2".GenomicsDBImport.err.log"}' | xargs rm -rf 

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done | awk 'NF==2{print $2".GenomicsDBImport.out.log"}' | xargs rm -rf 

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Import completed!" ${i}.GenomicsDBImport.err.log | grep "Import completed!")
done | awk 'NF==2{print $2}' > FAILED.txt
```

Then, perform GenomicsDBImport forfailed samples
- [run_GenomicsDBImport_for-failed-regions.sh](./scripts/run_GenomicsDBImport_for-failed-regions.sh)
```
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
```

Confirm all samples are successfully processed.
```
#Declare INTERVALS
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

## Generate VCF files
Generate GVCF files for the intervals
- [run_GenotypeGVCFs.sh](./scripts/run_GenotypeGVCFs.sh)
```
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
```

Identify failed files
```
cat *.GenotypeGVCFs.out.log | wc -l
0

cat *.GenotypeGVCFs.err.log | grep "Traversal complete." | wc -l
743

#Declare INTERVALS
INTERVALS=(`cat intervals.list`)

#Find failed chunk
for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Traversal complete." ${i}.GenotypeGVCFs.err.log | grep "Traversal complete.")
done | awk 'NF==2{print $2}' > FAILED.txt

#Delete failed files
for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Traversal complete." ${i}.GenotypeGVCFs.err.log | grep "Traversal complete.") \
| awk 'NF==2{print $2".vcf"}' 
done | xargs rm

for i in `seq 0 $((${#INTERVALS[@]}-1))`; do
paste -d "\t" <(echo ${INTERVALS[${i}]}) <(echo ${i}) <(grep "Traversal complete." ${i}.GenotypeGVCFs.err.log | grep "Traversal complete.") \
| awk 'NF==2{print $2".vcf.idx"}'
done  | xargs rm
```

Peform GenotypeGVCFs for the failed samples
- [run_GenotypeGVCFs_for-failed-regions.sh](./scripts/run_GenotypeGVCFs_for-failed-regions.sh)
```
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
thread=5
#Path to fasta
Genome_GATK_path="/path_to_reference_genome/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"

#Declare INTERVALS
INTERVALS=(`cat intervals.list`)

#Generate options for GenomicsDBImport
gvcf_files=""
for i in `seq 0 $((${#SampleNames[@]}-1))`; do
gvcf_files=${gvcf_files}"-V ${gvcf_path}/${SampleNames[${i}]}.g.vcf "
done

#Failed samples
FAILED=(`cat FAILED.txt`)

#Perform GenotypeGVCFs
echo "${FAILED[@]} " | xargs --delimiter=" " -P ${thread} -I {} sh -c "gatk --java-options "-Xmx50g" GenotypeGVCFs -R ${Genome_GATK_path} -genomicsdb-use-vcf-codec -V gendb://{}_db -O {}.vcf 2>{}.GenotypeGVCFs.err.log 1>{}.GenotypeGVCFs.out.log"

```

Confirm that all samples are processed successfully.
```
cat *.GenotypeGVCFs.out.log | wc -l
0

cat *.GenotypeGVCFs.err.log | grep "Traversal complete." | wc -l
745
```

- [run_bcftools_concat.sh](./scripts/run_bcftools_concat.sh)
```
#!/usr/bin/bash
#Declare INTERVALS
INTERVALS=(`cat intervals.list`)
#Declare vcf file names
vcf_files=(`seq 0 $((${#INTERVALS[@]}-1))`)
#Add suffix
vcf_files=( "${vcf_files[@]/%/.vcf}" )

#Concatenate vcf files
bcftools concat ${vcf_files[@]} > merged.vcf
```

Check the merged.vcf
```
cat <(grep -v "^#" ?.vcf) <(grep -v "^#" ??.vcf) <(grep -v "^#" ???.vcf) | wc -l
3294624
grep -v "^#" merged.vcf | wc -l
3294624
```

Extract SNP and Indel
- [run_extract_SNP_INDEL.sh](./scripts/run_extract_SNP_INDEL.sh)

```
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
```

Count number of rows
```
cat Stats_SNP_INDEL_SNP-INDEL.txt
59288076    12719000    72007076
```






