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
