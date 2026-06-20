#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=120G

unmask 0002

export WORK=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/VCF
cd $WORK

module load apptainer/1.3.4

repadapt_bcftools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/bcftools.1.16


########### Only filtering the VCF to exclude sites with QUAL < 30 and invariant ALT/ALT sites (AC = AN) ###########

apptainer exec $repadapt_bcftools bcftools filter -e 'AC=AN || MQ < 30' $WORK/Strongylocentrotus_purpuratus.vcf.gz -Oz > $WORK/rawg0132_Strongylocentrotus_purpuratus_sadler.vcf.gz

### As an alternative to the bcftools command above, vcftools can also be used to filter by QUAL:
### vcftools --gzvcf bplaty.vcf.gz --minQ 30 --recode --recode-INFO-all --stdout > bplaty_filtered.vcf


apptainer exec $repadapt_bcftools tabix -p vcf $WORK/rawg0132_Strongylocentrotus_purpuratus_sadler.vcf.gz