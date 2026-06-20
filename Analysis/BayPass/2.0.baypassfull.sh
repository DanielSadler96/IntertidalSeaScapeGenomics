#!/usr/bin/env bash
#SBATCH -J BayPassrun 
#SBATCH -c 8
#SBATCH -N 1 # on one node
#SBATCH -t 30:00:00 
#SBATCH --mem 60G 
#SBATCH -p general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=daniel.sadler@uvm.edu
#SBATCH -e logs/errors_%A_%a.txt
#SBATCH -o logs/output_%A_%a.txt
#SBATCH --array=1-5

unmask 0002

module load gcc/13.3.0
module load openmpi/5.0.5-ib

WORK=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/BayPass
cd $WORK

BAYPASS=/users/d/s/dsadler1/programmes/baypass_public-master/sources/./g_baypass

REP=${SLURM_ARRAY_TASK_ID} 

# Run BayPass
$BAYPASS -npop 11 -gfile $WORK/baypass_input_Balanus.txt -omegafile CoreModelBalanus_mat_omega.out -outprefix $WORK/CoreModelBalanus_$REP -nthreads 8

echo "done!"

