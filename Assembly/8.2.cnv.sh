#!/bin/bash
#SBATCH --job-name=CNV2
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --output=./slurmOutput/%x.%A_%a.out
#SBATCH --error=./slurmOutput/%x.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --array=1-144


#### calculate depth statistics for 83 samples -- see array number above and change accordingly ####

# Load needed modules
###### CHANGE THE LINES OF CODE BELOW TO LOAD THE CORRECT VERSION OF SAMTOOLS and BEDTOOLS IN YOUR MACHINE/SERVER  = samtools v.1.16.1   BEDtools v.2.27.1
module load apptainer/1.3.4

repadapt_samtools=https://depot.galaxyproject.org/singularity/samtools:1.16.1--h6899075_0
repadapt_bedtools=https://depot.galaxyproject.org/singularity/bedtools:2.27.1--0 

#module load samtools
#module load bedtools

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" realignedlist.txt)  ### list of realigned bam files
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list2.txt)  ### list of output names (just extract from input names removing bam suffix)
REFFILE=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/PurpleSeaUrchins/Ref

# dump depth of coverage at every position in the genome
apptainer run $repadapt_samtools samtools depth -aa $INPUT > $OUTPUT\.depth

# gene depth analysis
echo \n">>> Computing depth of each gene for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | apptainer run $repadapt_bedtools bedtools map -a $REFFILE/genes.bed -b stdin -c 4 -o mean -null 0 -g $REFFILE/genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1 > $OUTPUT\-genes.tsv

# sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' $REFFILE/genes.list $OUTPUT\-genes.tsv > $OUTPUT\-genes.sorted.tsv

# window depth analysis
echo \n">>> Computing depth of each window for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | apptainer run $repadapt_bedtools bedtools map -a $REFFILE/windows.bed -b stdin -c 4 -o mean -null 0 -g $REFFILE/genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1  > $OUTPUT\-windows.tsv

# sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' $REFFILE/windows.list $OUTPUT\-windows.tsv > $OUTPUT\-windows.sorted.tsv

# overall genome depth
echo \n">>> Computing depth of whole genome for $file <<<"\n
awk '{sum += $3; count++} END {if (count > 0) print sum/count; else print "No data"}' $OUTPUT\.depth > $OUTPUT\-wg.txt

rm -rf $OUTPUT\.depth
echo "DONE! Stage 1"



##############Stage2################

find . -name "*realigned.bam" | sed 's/.bam//g' | sed 's/^..//g' > list.txt

echo -e "location\t$(cut -f2 list.txt | sort | uniq | paste -s -d '\t')" > depthheader.txt

# get a list of sample names
cut -f2 list.txt | sort | uniq > samples.txt

### combine windowed depth analysis results
# get just the second (depth) column of each output file
while read samp; do cut -f2 ${samp}-windows.sorted.tsv > ${samp}-windows.sorted.depthcol ; done < samples.txt

# combine both columns of the first output file and add the second column of all other files
paste $(sed 's/^/.\//' samples.txt | sed 's/$/-windows.sorted.tsv/' | head -n 1) $(sed 's/^/.\//' samples.txt | sed 's/$/-windows.sorted.depthcol/' | tail -n +2) > ./combined-windows.temp

# add header
cat ./depthheader.txt ./combined-windows.temp > ./combined_windows.tsv

### combine gene depth analysis results
# get just the second (depth) column of each output file
while read samp; do cut -f2 ./${samp}-genes.sorted.tsv > ./${samp}-genes.sorted.depthcol ; done < ./samples.txt

# combine both columns of the first output file and add the second column of all other files
paste $(sed 's/^/.\//' ./samples.txt | sed 's/$/-genes.sorted.tsv/' | head -n 1) $(sed 's/^/.\//' ./samples.txt | sed 's/$/-genes.sorted.depthcol/' | tail -n +2) > ./combined-genes.temp

# add header
cat ./depthheader.txt ./combined-genes.temp > ./combined_genes.tsv

### make a table of whole-genome depths from samtools
while read samp; do echo -e $samp"\t"$(cat ./$samp-wg.txt); done < ./samples.txt > combined_wg.tsv


rm *temp
rm *depthcol
rm depthheader.txt
rm samples.txt

echo "DONE! Stage 2"
