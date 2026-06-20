#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G 
#SBATCH --array=1-1

###this will automatically change everyones permissions to the group 
unmask 0002

####we are now explicitly stating the working directory - i.e. 
export WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/bwa_output

cd $WORK

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/deduplist.txt) ### List of input deduplicated bam files (new list of _dedup.bam)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/list2.txt) ### List of output names (just remove .bam) from the inputs (same as rmdup one)
NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/list3.txt)   ### Here you want to extract the sample name from the input name, which is used to set the read IDs. Can be the same as list2.txt


### Here we add read groups, we start with our deduplicated bam files and we get a deduplicated bam with read groups assigned per sample/library
###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF PICARD IN YOUR MACHINE/SERVER  = Picard Tools v.2.26.3
module load apptainer/1.3.4
repadapt_picard=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/picard.2.26.2


apptainer exec --bind $WORK $repadapt_picard java -Xmx30G -jar /usr/local/share/picard-2.26.3-0/picard.jar AddOrReplaceReadGroups \
        I=$INPUT \
        O=$OUTPUT\_RG.bam \
        RGID=$NAME \
        RGLB=$NAME\_LB \
        RGPL=ILLUMINA RGPU=unit1 RGSM=$NAME