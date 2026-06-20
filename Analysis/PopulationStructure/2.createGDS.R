
library(SeqArray)

vcf.fn <- "Balanus_glandula_filtered.vcf.gz"                
gds.fn <- "Balanus_glandula_filtered.gds"
seqVCF2GDS(vcf.fn, gds.fn, parallel = TRUE)


#!/bin/bash
#SBATCH --job-name=GDS
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G

module load Rtidyverse

Rscript --vanilla  createGDS.R

echo "Job complete"