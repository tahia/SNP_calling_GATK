#!/bin/bash
#SBATCH -J Job
#SBATCH -o Job.o%j
#SBATCH -e Job.e%j
#SBATCH -N 4
#SBATCH -n 4
#SBATCH -p development
#SBATCH -t 01:00:00
#SBATCH -A P.hallii_expression


ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.5.0

CMD=$1
EXECUTABLE=$TACC_LAUNCHER_DIR/init_launcher
$TACC_LAUNCHER_DIR/paramrun $EXECUTABLE $CMD

echo "DONE";
date;

