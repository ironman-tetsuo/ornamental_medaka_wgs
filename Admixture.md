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
## Visualize the CV values for each K value
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
