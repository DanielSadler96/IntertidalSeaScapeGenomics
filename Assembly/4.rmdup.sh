#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=30G 
#SBATCH --array=1-1

###this will automatically change everyones permissions to the group 
unmask 0002

####we are now explicitly stating the working directory - i.e. 
export WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/bwa_output

cd $WORK


###prepare names as
### ls *.bam > list1.txt 
### cat list1.txt | cut -d "_" -f1,2 > list2.txt
### The lists below need to follow the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/list1.txt) ### list of input bam files (output of script 03)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/list2.txt) ### list of output names
 
###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF PICARD IN YOUR MACHINE/SERVER  = Picard Tools v.2.26.3
module load apptainer/1.3.4
repadapt_picard=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/picard.2.26.2

### Here we remove duplicates. We feed it a bam, and we get a deduplicated bam per sample/library

apptainer exec \
    --bind $WORK \
    $repadapt_picard \
    java -Xmx30G -jar /usr/local/share/picard-2.26.3-0/picard.jar MarkDuplicates \
        INPUT=$INPUT \
        OUTPUT=${OUTPUT}_dedup.bam \
        METRICS_FILE=${OUTPUT}_DUP_metrics.txt \
        VALIDATION_STRINGENCY=SILENT \
        REMOVE_DUPLICATES=true
