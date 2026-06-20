#!/bin/bash
#SBATCH --job-name=gatk_indel_realignment
#SBATCH --partition=week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G
#SBATCH --time=72:00:00
#SBATCH --array=1-140
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu

# Input / Output from lists

INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" RG.list)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list2.txt)

# Load Apptainer

module purge
module load apptainer/1.3.4

# Containers

repadapt_samtools=https://depot.galaxyproject.org/singularity/samtools:1.16.1--h6899075_0
repadapt_gatk=https://depot.galaxyproject.org/singularity/gatk:3.8--10

# Reference genome

REFERENCE=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref/GCF_000002235.5_Spur_5.0_genomic.fna


# Index BAM

echo "Indexing BAM with samtools..."
apptainer exec --cleanenv --bind $PWD $repadapt_samtools \
    samtools index $INPUT

# RealignerTargetCreator

echo "Running RealignerTargetCreator..."

apptainer exec --cleanenv --bind $PWD $repadapt_gatk \
    java -Xmx180g -jar /usr/local/opt/gatk-3.8/GenomeAnalysisTK.jar \
    -T RealignerTargetCreator \
    -R $REFERENCE \
    -I $INPUT \
    -o ${OUTPUT}.intervals

# IndelRealigner

echo "Running IndelRealigner..."

apptainer exec --cleanenv --bind $PWD $repadapt_gatk \
    java -Xmx180g -jar /usr/local/opt/gatk-3.8/GenomeAnalysisTK.jar \
    -T IndelRealigner \
    -R $REFERENCE \
    -I $INPUT \
    -targetIntervals ${OUTPUT}.intervals \
    --consensusDeterminationModel USE_READS \
    -o ${OUTPUT}_realigned.bam

echo "Indel realignment complete."
