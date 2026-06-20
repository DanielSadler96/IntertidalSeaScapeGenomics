#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G 

### This is to create gatk index of ref genome needed for indel realignment
### Keep the output files of this command in the same dir where you keep the reference genome fasta
###this will automatically change everyones permissions to the group 
module load apptainer/1.3.4

unmask 0002

####we are now explicitly stating the working directory - i.e. CHANGE TO REF PATH
export WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref
cd $WORK

REF=GCF_000002235.5_Spur_5.0_genomic.fna ###change to ref fasta name
OUTPUT=GCF_000002235.5_Spur_5.0_genomic ###refname (no .fna)

repadapt_samtools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/samtools.1.16.1
repadapt_picard=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/picard.2.26.2

apptainer run $repadapt_samtools samtools faidx $WORK/$REF

###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF PICARD IN YOUR MACHINE/SERVER  = Picard Tools v.2.26.3
apptainer exec --bind $WORK $repadapt_picard java -Xmx40G -jar /usr/local/share/picard-2.26.3-0/picard.jar CreateSequenceDictionary \
        R=$REF \
        O={$OUTPUT}.dict