#!/bin/bash
#SBATCH --job-name=concat
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

export WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/VCF
cd $WORK

###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF BCFTOOLS IN YOUR MACHINE/SERVER  = bcftools v. 1.16
module load apptainer/1.3.4

repadapt_bcftools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/bcftools.1.16

### Concatenate all the chromsome vcfs produced in script 09. 
### list.txt is a list of the 14 (in this case) vcfs produced in script 09.
### Here we concatenate them in a single vcf

apptainer exec $repadapt_bcftools bcftools concat -f $WORK/list.txt -Oz > $WORK/Strongylocentrotus_purpuratus.vcf.gz
apptainer exec $repadapt_bcftools tabix -p vcf $WORK/Strongylocentrotus_purpuratus.vcf.gz
