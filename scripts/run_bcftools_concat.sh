#!/usr/bin/bash
#Declare INTERVALS
INTERVALS=(`cat intervals.list`)
#Declare vcf file names
vcf_files=(`seq 0 $((${#INTERVALS[@]}-1))`)
#Add suffix
vcf_files=( "${vcf_files[@]/%/.vcf}" )

#Concatenate vcf files
bcftools concat ${vcf_files[@]} > merged.vcf
