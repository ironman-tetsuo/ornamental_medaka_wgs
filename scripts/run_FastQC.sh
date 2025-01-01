#!/bin/bash
#SBATCH --job-name=run_FastQC
#SBATCH --cpus-per-task=4
#SBATCH --mem=10GB
#SBATCH --partition=basic
#SBATCH --time=02-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

#Prepare the environment
module load fastqc

SampleNames=(
"sample1"
"sample2"
"sample3"
"sample4"
)
fastq_path="fastq_path"
thread=4

echo "${SampleNames[@]} " | xargs --delimiter=" " -P ${thread} -I {} sh -c "fastqc --nogroup -o ./ ${fastq_path}/{}_R1.fastq.gz"
echo "${SampleNames[@]} " | xargs --delimiter=" " -P ${thread} -I {} sh -c "fastqc --nogroup -o ./ ${fastq_path}/{}_R2.fastq.gz"

#fastqc -t ${thread} --nogroup -o ./ ${fastq_path}/${SampleNames}_R1.fastq.gz
#fastqc -t ${thread} --nogroup -o ./ ${fastq_path}/${SampleNames}_R2.fastq.gz
