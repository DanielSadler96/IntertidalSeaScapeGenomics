#!/bin/bash
#SBATCH --job-name=subsetVCF
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=120G
#SBATCH --array=1-1


###Pop_prefix = pop names

unmask 0002

module load gcc
module load vcftools 


WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula

cd $WORK

#cut -d'_' -f1 <(bcftools query -l Balanus_glandula_filtered.vcf.gz) | sort -u > pop_prefixes.txt

#for pop in $(cat pop_prefixes.txt); do
#    bcftools query -l Balanus_glandula_filtered.vcf.gz | grep "^${pop}_^sorted.bam" > ${pop}_samples.txt
#done


pop=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/pop_prefixes.txt)


vcftools --gzvcf Balanus_glandula_filtered.vcf.gz \
        --keep ${pop}_samples.txt \
        --freq \
        --out ${pop}_AF


vcftools --gzvcf Balanus_glandula_filtered.vcf.gz \
        --keep ${pop}_samples.txt \
        --count \
        --out ${pop}_AF_count






