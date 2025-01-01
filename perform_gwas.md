# GWAS analysis
Check the phenotype list.
```
head -n 1 metafiles/medaka_pheno14_Kon-add-wild-samples.tsv   | tr "\t" "\n" | awk 'BEGIN{OFS="\t"}{print NR,$1}' | tail -n +9 | tr -d "\r" > column_phenotype.txt
head -n 5 column_phenotype.txt
9    yokihi2
 10    gold2
 11    white2
 12    blue
 13    orochi
```

With the following script, GWAS will be performed on the variant data set in PLINK BED/BIM/FAM format.
```
#parameters for variant calling
MISSING=0.70
MAF=0.05

#Variables
COLUMN=(`awk '{print $1}'  column_phenotype.txt`)
PHENOTYPE=(`awk '{print $2}'  column_phenotype.txt`)

#File path
ped_path="/path_to_bed_bim_fam"
#GWAS
for k in `seq 0 $((${#COLUMN[@]}-1))`; do
plink --allow-extra-chr --chr-set 24 no-xy no-mt --bfile ${ped_path}/merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.with-ID --assoc --adjust --out ${PHENOTYPE[${k}]} --pheno ${PHENOTYPE[${k}]}.txt --allow-no-sex
done
```
Generate gwas files
- [generate_gwas_files.sh](./scripts/generate_gwas_files.sh)
```
#!/usr/bin/bash

#path to VCF
vcf_path="/path_to_vcf_file"
#Variables
COLUMN=(`awk '{print $1}'  column_phenotype.txt`)
PHENOTYPE=(`awk '{print $2}'  column_phenotype.txt`)

#Parameters for variant filtering
MISSING=0.70
MAF=0.05

for k in `seq 0 $((${#COLUMN[@]}-1))`; do
tail -n +2 ${PHENOTYPE[${k}]}.assoc.adjusted | awk '{print $2,$1,$3}' | sort -k1f > tmp1
grep -v "^#" ${vcf_path}/merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.with-ID.vcf | awk '{print $3, $2}' | sort -k1f >  SNP-BP.txt
join -1 1 -2 1 tmp1 SNP-BP.txt | awk 'BEGIN {OFS="\t"}{print $1,$2,$4,$3}' | sort -k1,1f > ${PHENOTYPE[${k}]}.gwas
done
```


Script for manhattan plot.
- [run_qqman.R](./scripts/run_qqman.R)


```
library("qqman")
Scaffold_Name_Number <- read.table(file="/path/Scaffold_Name-Number.txt", header=FALSE, stringsAsFactor=F, row.names=1)
COLOR <- c(rep(c("gray34", "gray74"), 25))
phenotype <- read.table("column_phenotype.txt", header=F, stringsAsFactors=F)[,2]
YLIM <- c(0, 80)
CEX <- 0.01
WIDTH <- 3000
HEIGHT <- 1000

for(i in 1:length(phenotype)){
dat <- read.table(file=paste(phenotype[i], ".gwas", sep=""), header=FALSE, stringsAsFactor=F)
colnames(dat) <- c("SNP", "CHR", "BP", "P")
dat2 <- as.data.frame(cbind(dat$SNP, Scaffold_Name_Number[as.character(dat$CHR),1], dat$BP, dat$P))
colnames(dat2) <- c("SNP", "CHR", "BP", "P")

dat2$CHR <- as.numeric(dat2$CHR)
dat2$BP <- as.numeric(dat2$BP)
dat2$P <- as.numeric(dat2$P)

dat3 <- subset(dat2, CHR<=24)

tiff(paste("./Figures/chromosomes/", phenotype[i], "_chromosomes_", YLIM[2], ".tiff", sep=""), width = WIDTH, height = HEIGHT, units="px", res=300, pointsize=10)
manhattan(dat3, logp=TRUE, ylim=YLIM, suggestiveline = F, genomewideline = F, col = COLOR, cex=CEX, main=phenotype[i])
dev.off()

}
```

Generate manhattan plots.
```
R CMD BATCH --slave --vanilla run_qqman.R run_qqman.R.log
```
