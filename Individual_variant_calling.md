# Individual variant calling for generating GVCF files

For individual variant calling, peform gatk HaplotypeCaller on each bam.

- [run_HaplotypeCaller.sh](scripts/run_HaplotypeCaller.sh)
```
#!/usr/bin/bash
#Declare variables for SRR IDs
SampleNames=(`tail -n +2 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv | awk -F "\t" 'BEGIN{OFS="\t"}{print $6}'  | xargs`)
#Bam path
bam_path="/path_to_bam/"
#CPU usage
thread=45

#path_to_the_indexed_path
Genome_GATK_path="/path_to_indexed_reference_fasta/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa"
#Generate GVCF
echo "${SampleNames[@]} " | xargs --delimiter=" " -P ${thread} -I {} sh -c "gatk --java-options "-Xmx10g" HaplotypeCaller -R ${Genome_GATK_path} -I ${bam_path}/{}.sort.bam -O {}.g.vcf.gz --emit-ref-confidence GVCF 2>{}.HaplotypeCaller.err.log 1>{}.HaplotypeCaller.out.log"
```
