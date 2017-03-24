#!/bin/bash
#SBATCH -J Job
#SBATCH -o Job.o%j
#SBATCH -e Job.e%j
#SBATCH -N 4
#SBATCH -n 4
#SBATCH -p development
#SBATCH -t 01:00:00
#SBATCH -A P.hallii_expression


module load fastx_toolkit
module load bwa
module load launcher
ml gatk/2.5.2

CMD=$1
EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $CMD

echo "DONE";
date;

