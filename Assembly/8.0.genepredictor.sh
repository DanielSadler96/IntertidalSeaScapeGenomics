#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH -e ./slurmOutput/augustus.%A_%a.err 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=40G 

###stage needed if no gff!

### Run Augustus

module load apptainer/1.3.4

AUGUSTUS=/gpfs1/cont/augustus/augustus-3.5.0.sif 
 
#### user parameters
SPECIES=fly
home=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/Ref 
target=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/Ref/Balanus_glandula.fna
PROJECT=Balanus_glandula

##version
##singularity run $AUGUSTUS augustus --version   
##paramlist
##singularity run $AUGUSTUS augustus --help
##singularity run $AUGUSTUS augustus --species=help

cp $target_full_address ./

apptainer exec \
$AUGUSTUS augustus \
--strand=both \
--gff3=on \
--species=$SPECIES \
$target > \
$PROJECT.genepred.gff3