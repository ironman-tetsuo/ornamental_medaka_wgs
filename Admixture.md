# Admixture analysis
## Conduct admixture analysis.
- [run_admixture.sh](./scripts/run_admixture.sh)
```
#!/bin/bash
#Declare variables
ped_map_path="."
thread=45

#Declare the parameters for variant filtering
MISSING=0.90
MAF=0.05

#Calculate admixture plot
for i in `seq 1 30`; do
admixture --cv=100 -j${thread} ${ped_map_path}/merged_SNP_INDEL_--max-missing${MISSING}_--maf${MAF}.with-ID.bed ${i} | tee log${i}.out
done
```
## Visualize the CV values and barplot for each K value
Retrieve CV values.
```
grep -h CV log*.out | awk '{print $3, $4}' | tr -d "(" | tr -d ")" | tr -d "=" | tr -d ":" | tr -d "K" | sort -k1n > CV-errors.txt
```
Plot with R.
```
WIDTH=4000
HEIGHT=4000
filename="CV-errors.txt"
dat <- read.table(filename, header=F)
tiff("./Figures/Cross-validation-error_100times.tiff", width = WIDTH, height = HEIGHT, res=600)
plot(x=dat$V1, y=dat$V2, type="l", ylab="Cross-validation error", xlab="K")
#abline(v=3, col="red", lty=2)
#text(x=4, y=1.3, labels="K = 3")
dev.off()
```
Plot barplots.
```
#Declare the fine name of the result file of the admixture analysis
MISSING <- "0.90"
MAF <- "0.05"
Input <- paste("merged_SNP_INDEL_--max-missing", MISSING,"_--maf", MAF, ".with-ID", sep="")

#Read sample names
ped_names <- read.table(paste(Input, ".name", sep=""), header=F, stringsAsFactor=F)
sample_names <- read.table("./metafiles/medaka_pheno14_Kon-add-wild-samples_with-DRP005544.tsv", stringsAsFactors=F, header=T)
rownames(sample_names) <- sample_names$bamID_DONT_change
sample_names <- sample_names[ped_names[,1], ]
sample_names <- as.data.frame(sample_names)

###K=2###
#色のセットを作成する
COLOR <- c("orange", "red")
#Plot
K <- 2
tbl <- read.table(paste(Input, ".", K, ".Q", sep=""))
par(mar = c(30, 3, 3, 2))
tiff(paste("./Figures/", K, ".tiff", sep=""), width = 8000, height = 1200, res=300)
barplot(t(as.matrix(tbl)), col=COLOR, ylab="Ancestry", border=NA, names.arg=sample_names[,7], las=2, cex.names=0.3, beside=F)
dev.off()

###K=3###
#Color set
COLOR <- c("green", "red",  "orange")
#図示
K <- 3
tbl <- read.table(paste(Input, ".", K, ".Q", sep=""))
par(mar = c(30, 3, 3, 2))
tiff(paste("./Figures/", K, ".tiff", sep=""), width = 8000, height = 1200, res=300)
barplot(t(as.matrix(tbl)), col=COLOR, ylab="Ancestry", border=NA, names.arg=sample_names[,7], las=2, cex.names=0.3, beside=F)
dev.off()

###K=4###
#Color set
COLOR <- c("red", "orange", "blue", "green")
#Plot
K <- 4
tbl <- read.table(paste(Input, ".", K, ".Q", sep=""))
par(mar = c(30, 3, 3, 2))
tiff(paste("./Figures/", K, ".tiff", sep=""), width = 8000, height = 1200, res=300)
barplot(t(as.matrix(tbl)), col=COLOR, ylab="Ancestry", border=NA, names.arg=sample_names[,7], las=2, cex.names=0.3, beside=F)
dev.off()

###K=5###
#Color set
COLOR <- c("red", "orange", "blue", "green", "magenta")
#Plot
K <- 5
tbl <- read.table(paste(Input, ".", K, ".Q", sep=""))
par(mar = c(30, 3, 3, 2))
tiff(paste("./Figures/", K, ".tiff", sep=""), width = 8000, height = 1200, res=300)
barplot(t(as.matrix(tbl)), col=COLOR, ylab="Ancestry", border=NA, names.arg=sample_names[,7], las=2, cex.names=0.3, beside=F)
dev.off()

###K=6###
#Color set
COLOR <- c("red", "orange", "blue", "green", "magenta", "black")
#Plot
K <- 6
tbl <- read.table(paste(Input, ".", K, ".Q", sep=""))
par(mar = c(30, 3, 3, 2))
tiff(paste("./Figures/", K, ".tiff", sep=""), width = 8000, height = 1200, res=300)
barplot(t(as.matrix(tbl)), col=COLOR, ylab="Ancestry", border=NA, names.arg=sample_names[,7], las=2, cex.names=0.3, beside=F)
dev.off()
```
