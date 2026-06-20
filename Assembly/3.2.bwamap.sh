#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./logs/bwarun.%A_%a.out
#SBATCH --error=./logs/bwarun.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dsadler1@uvm.edu
#SBATCH --time=30:00:00
#SBATCH --cpus-per-task=4 
#SBATCH --mem-per-cpu=30G 
#SBATCH --array=1-1


###this will automatically change everyones permissions to the group 
unmask 0002

####we are now explicitly stating the working directory - i.e. 
export WORK=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/trimmed

cd $WORK

#### All these lists below need to follow same order
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/R1input.txt) ### List of trimmed R1 fastq reads (produced with script 01)
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/R2input.txt) ### List of trimmed R2 fastq reads (produced with script 01)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORK/sample_names.txt) ### List of output names -- extract the meaningful part of the name from the trimmed reads names. Ther>
REF=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref/GCF_000002235.5_Spur_5.0_genomic.fna
OUTDIR=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins

echo "inputs"
echo $INPUT1
echo $INPUT2
echo $OUTPUT
echo "REF:"
echo $REF

###### CHANGE THE LINE OF CODE BELOW TO LOAD THE CORRECT VERSION OF SAMTOOLS AND BWA IN YOUR MACHINE/SERVER  = bwa-mem v.0.7.17-r1188   samtools v.1.16.1
module load apptainer/1.3.4

repadapt_bwa=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/bwa.0.7.17
repadapt_samtools=/gpfs1/home/d/s/dsadler1/Pi_shared/MultiSpeciesGO/programmes/samtools.1.16.1
#repadapt_bwa=https://depot.galaxyproject.org/singularity/bwa:0.7.17--h5bf99c6_8
#repadapt_samtools=https://depot.galaxyproject.org/singularity/samtools:1.16.1--h6899075_0
#### We end up with 1 bam file per sample after this. If you had multiple libraries per sample, you'd end up with 1 bam per library

apptainer run $repadapt_bwa bwa mem -t 4 $REF $INPUT1 $INPUT2  > $OUTDIR/bwa_output/$OUTPUT\.sam

echo "step1 run"

apptainer run $repadapt_samtools samtools view -Sb -q 10 $OUTDIR/bwa_output/$OUTPUT\.sam > $OUTDIR/bwa_output/$OUTPUT\.bam

echo "step 2 run"

rm $OUTDIR/bwa_output/$OUTPUT\.sam

apptainer run $repadapt_samtools samtools sort --threads  4 $OUTDIR/bwa_output/$OUTPUT\.bam > $OUTDIR/bwa_output/$OUTPUT\_sorted.bam

echo "step 3 run"

rm $OUTDIR/bwa_output/$OUTPUT\.bam

apptainer run $repadapt_samtools samtools index $OUTDIR/bwa_output/$OUTPUT\_sorted.bam

echo "step 4 run, done!"
