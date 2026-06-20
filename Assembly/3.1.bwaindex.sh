#!/bin/bash
#SBATCH --job-name=bwaindex
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=120G

### Here we just create the bwa index of the reference genome, needed for mapping
### Keep the output of this command in the same dir where you keep the reference genome fasta

##downlaod ref
#/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/./datasets download genome accession GCA_049308085.2 --include gff3,rna,cds,protein,genome,seq-report


###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF BWA IN YOUR MACHINE/SERVER  = bwa-mem v.0.7.17-r1188
module load apptainer/1.3.4
repadapt_bwa=https://depot.galaxyproject.org/singularity/bwa:0.7.17--h5bf99c6_8

apptainer run $repadapt_bwa bwa index -a bwtsw GCF_000002235.5_Spur_5.0_genomic.fna