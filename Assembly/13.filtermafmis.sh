#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./logs/%x.%A_%a.out
#SBATCH --error=./logs/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G

export WORK=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Conner/analyses
cd $WORK

module load apptainer/1.3.4

repadapt_bcftools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/bcftools.1.16

VCF=Balanus_glandula_filtered.vcf.gz

########### Only filtering the VCF to exclude sites with QUAL < 30 and invariant ALT/ALT sites (AC = AN) ###########

apptainer exec $repadapt_bcftools bcftools filter --threads 4 -e 'F_MISSING > 0.3 || MAF[0]<0.05 || MAF[0]>0.95' -O z -o Balanus_glandula_filt2.vcf.gz $VCF

apptainer exec $repadapt_bcftools tabix Balanus_glandula_filt2.vcf.gz

apptainer exec $repadapt_bcftools bcftools filter --threads 4 -S . -e 'FMT/DP<3' -O z -o Balanus_glandula_filt3.vcf.gz Balanus_glandula_filt2.vcf.gz

apptainer exec $repadapt_bcftools tabix Balanus_glandula_filt3.vcf.gz
