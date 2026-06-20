#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --array=1-140

###CHANGE SAMPLE NAMES USING META 

module load apptainer/1.3.4
FASTP_IMG=https://depot.galaxyproject.org/singularity/fastp:0.20.1--h8b12597_0

##change path 
RAW_READS=/users/d/s/dsadler1/Pi_shared/RepAdapt/fastq
##comment out once done 
mkdir -p $RAW_READS
OUTDIR=/users/d/s/dsadler1/Pi_shared/RepAdapt/trimmed
mkdir -p $OUTDIR

# Get list of R1 files
R1_LIST=($(ls $RAW_READS/*_1.fastq | sort))

R1=${R1_LIST[$SLURM_ARRAY_TASK_ID-1]}

# Derive R2
R2=${R1/_1.fastq/_2.fastq}

# Extract sample name
SAMPLE=$(basename $R1 _1.fastq)

echo "Processing sample: $SAMPLE"
echo "R1: $R1"
echo "R2: $R2"

apptainer run $FASTP_IMG fastp \
    -w 4 \
    -i $R1 \
    -I $R2 \
    -o $OUTDIR/${SAMPLE}_R1_trimmed.fastq.gz \
    -O $OUTDIR/${SAMPLE}_R2_trimmed.fastq.gz