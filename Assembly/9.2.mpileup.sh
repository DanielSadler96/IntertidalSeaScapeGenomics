#!/bin/bash
#SBATCH --job-name=mpileup
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --array=1-1

module load apptainer/1.3.4

export WORK=//gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/bwa_output

cd $WORK
# ------------------------------
# Container
# ------------------------------
repadapt_bcftools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/bcftools.1.16

# ------------------------------
# Input files
# ------------------------------
REFPATH=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref
REF=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref/GCF_000002235.5_Spur_5.0_genomic.fna
BAMLIST=realigned.txt
PLOIDY=ploidymap.txt
OUTPUT=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/VCF

# ------------------------------
# Get scaffold chunk for this array job
# ------------------------------
CHUNK_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $REFPATH/chromosome_list.txt)

# Convert scaffold list into comma-separated string
CHR=$(paste -sd, $CHUNK_FILE)

echo "Processing scaffold list: $CHUNK_FILE"
echo "CHR: $CHR"

# ------------------------------
# Run mpileup + call
# ------------------------------
apptainer exec $repadapt_bcftools \
bcftools mpileup \
    --threads 4 \
    -Ou \
    -f $REF \
    --bam-list $BAMLIST \
    -q 5 \
    -r $CHR \
    -I \
    -a FMT/AD,FMT/DP | \
apptainer exec $repadapt_bcftools \
bcftools call \
    --threads 4 \
    -S $PLOIDY \
    -G - \
    -f GQ \
    -mv \
    -Ov \
    -o $OUTPUT/Purple_chr_${SLURM_ARRAY_TASK_ID}.vcf
    