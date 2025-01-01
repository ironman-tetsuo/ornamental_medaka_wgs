# PCA analysis
## Perform PCA
PCA can be performed from the PLINK BED/BIM/FAM files using PLINK.
```
plink \
--allow-extra-chr \
--bfile merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--out merged_SNP_INDEL_--max-missing0.90_--maf0.05 \
--pca 50
```
## Plotting results
Plot the PCA result using R.
Initiate R
```
R
```
Plotting as follows.
```
#Load data
eigenvec <- read.table("merged_SNP_INDEL_--max-missing0.90_--maf0.05.eigenvec", header=F, stringsAsFactor=F)
eigenval <- read.table("merged_SNP_INDEL_--max-missing0.90_--maf0.05.eigenval", header=F, stringsAsFactor=F)
ped_names <- read.table("merged_SNP_INDEL_--max-missing0.90_--maf0.05.name", header=F, stringsAsFactor=F)

#Load sample names
sample_names1 <- (read.table("./metafiles/medaka_pheno14_Kon-add-wild-samples.tsv", stringsAsFactors=F, header=T, sep="\t"))
rownames(sample_names1) <- sample_names1$bamID_DONT_change
sample_names1 <- cbind("strain",sample_names1)
colnames(sample_names1)[1] <- "Region"

sample_names2 <- (read.table("./metafiles/DRP005544_SraRunTable_v3.tsv", stringsAsFactors=F, header=T, sep="\t"))
#rownames(sample_names2) <- paste(sample_names2$ID, "_", sample_names2$fixedID_DONT_change, sep="")
rownames(sample_names2) <-  sample_names2$bamID_DONT_change

sample_names <- cbind(
c(sample_names1$fixedID_DONT_change, sample_names2$fixedID_DONT_change),
c(sample_names1$Region, sample_names2$Region)
)
rownames(sample_names) <- c(rownames(sample_names1), rownames(sample_names2))
colnames(sample_names) <- c("fixedID_DONT_change", "Region")

sample_names <- sample_names[ped_names[,1], ]
sample_names <- as.data.frame(sample_names)

#Declare colors
#Tol_light <- c('#BBCC33', '#AAAA00', '#77AADD', '#EE8866', '#EEDD88', '#FFAABB', '#99DDFF', '#44BB99', '#DDDDDD')
COLOR <- c("#44BB99", "#EE8866", "#77AADD", "#FFAABB", "#BBCC33", "#DDDDDD")
names(COLOR) <- c("N.JPN", "S.JPN", "Tajima-Tango", "E.KOR", "W.KOR", "strain")

#Total variance
VARIANCE <- sum(eigenval$V1)

#Contribution rates for PCs
 (100*eigenval/VARIANCE)[1:6,]
[1] 56.086754  7.230968  4.232954  3.024593  1.926164  1.889942

#Eigenvalues for each PC
png(file="./Figures/Eigenvalues.png", width = 1000, height = 1000)
barplot((100*eigenval/VARIANCE)[1:6,], names.arg=c(paste("PC", 1:6, sep="")), las=2, ylim=c(0,60))
dev.off()

#Plot PC1 and PC2
CEX<-2
png(file="./Figures/PC1-PC2_v1.png", width = 1000, height = 1000)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2")
text(x=eigenvec$V3, y=eigenvec$V4, labels=sample_names$fixedID_DONT_change, cex=1, pos=4, col="black")
dev.off()

CEX<-2
png(file="./Figures/PC1-PC2_v1_without-label.png", width = 1000, height = 1000)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2")
dev.off()

CEX<-1
tiff(file="./Figures/PC1-PC2_v1.tiff", width = 10000, height = 10000, res=600)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2")
text(x=eigenvec$V3, y=eigenvec$V4, labels=sample_names$fixedID_DONT_change, cex=CEX, pos=4, col="black")
dev.off()

#Plot with color
#Normal resolution
CEX<-2
png(file="./Figures/PC1-PC2_with_color_v1.png", width = 1000, height = 1000)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2", col=COLOR[sample_names$Region])
text(x=eigenvec$V3, y=eigenvec$V4, labels=sample_names$fixedID_DONT_change, cex=1, pos=4, col="black")
legend("topright", legend = names(COLOR), col = COLOR, pch = 16, cex=2)
dev.off()

#High resolution
CEX<-2
tiff(file="./Figures/PC1-PC2_with-color_v1.tiff", width=10000, height=10000)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2", col=COLOR[sample_names$Region])
text(x=eigenvec$V3, y=eigenvec$V4, labels=sample_names$fixedID_DONT_change, cex=1, pos=4, col="black")
legend("topright", legend = names(COLOR), col = COLOR, pch = 16, cex=2)
dev.off()

CEX<-1.3
png(file="./Figures/PC1-PC2_v1_without-label_with_color.png", width = 1000, height = 1000)
plot(x=eigenvec$V3, y=eigenvec$V4,  pch=16, cex=CEX, cex.lab=1.0, cex.axis=1.5, cex.main=1.0, main="Coplot of PC1 and PC2", xlab="PC1", ylab="PC2", col=COLOR[sample_names$Region])
dev.off()
```
