# Generation of manhattan plots

Since plotting manhattan plot takes some time, a R batch script for manhattan plot is generated firstly.
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
