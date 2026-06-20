#!/bin/bash
#SBATCH --job-name=SRA
#SBATCH --output=SRA_%A_%a.out
#SBATCH --error=SRA_%A_%a.err
#SBATCH --time=48:00:00
#SBATCH --mem=240G
#SBATCH --cpus-per-task=8
#SBATCH --partition=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu

## move to the appropriate directory
cd /gpfs2/scratch/pi/mpespeni/RepAdapt

## load software
module load gcc/13.3.0-xp3epyt
module load sratoolkit/3.0.0-y2rspiu

##configure make sure this works!
vdb-config --interactive

## we use NCBI's SRA toolkit - it's AWFUL
## prefetch downloads an un-useable SRA file
##input can be renamed, it is simply your list of SRR files (I would do these in batches to avoid mem probs)
while read p; do prefetch "$p" --max-size 80G ; done < Balanuslist

echo "sra download done"

## fasterq-dump will convert the files to FASTQ
while read p; do fasterq-dump --split-files "$p"/"$p".sra ; done < Balanuslist

my_job_header

date
echo "done"
