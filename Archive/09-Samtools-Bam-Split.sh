##########################################################################################################################
# This script is a part of genome-wide SNP Calling Pipeline for Plants by implementing Genome Analysis Toolkit (GATK)    #
# For further information about GATK please visit : https://gatk.broadinstitute.org/hc/en-us                             #
# Detail description of this pipe can be found in github: https://github.com/tahia/SNP_calling_GATK                      #
# Author : Taslima Haque                                                                                                 #
# Last modified: 12th Feb,2021                                                                                           #
# Please send your query to the author at: taslima@utexas.edu or tahiadu@gmail.com                                       #
##########################################################################################################################



############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V3 # output directory. It must be created before running the script
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/JGI_DL_78_Design.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp

CHRFIL=/work/02786/taslima/stampede2/dbs/PH/PhalliiHAL_496_v2.0.chr

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.
#FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
#FH.2.06 1       AGBTB   8829.1.113057.GATCAG
#FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
#FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
#FH.7.06 1       YPGT    8577.7.104714.ACGATA

# load required module in TACC
ml intel/17.0.4
ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.8.0
LC_ALL=C

############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

########################################## Step 09: SPLIT bam files by CHR ################################################

if [ -e splitbam.param ]; then rm splitbam.param; fi
if [ -e bam-index-3.param ]; then rm bam-index-3.param; fi
for f in `ls $outDir/MarkDup/*_dedup.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_dedup.bam}
    while read line
    do
    	OFIL1="${outDir}/BAMSPLIT/${NAME}_${line}.bam"
        OFIL2="${outDir}/BAMSPLIT/${NAME}_${line}.bai"
    	echo "samtools view -b $f $line -o $OFIL1 --threads 7"  >>splitbam.param 
        echo "java -jar -Xmx7G -Xms1G $TACC_PICARD_DIR/build/libs/picard.jar BuildBamIndex OUTPUT=$OFIL2 INPUT=$OFIL1 VALIDATION_STRINGENCY=LENIENT" >>bam-index-3.param
    done <$CHRFIL
done


Core=`wc -l splitbam.param  |cut -f1 -d ' '`
if (( $Core % 9 == 0)); then Node="$(($Core/9))";
        else  Node="$((($Core/9)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J splitbam --mail-user=taslima@utexas.edu -N $Node -n $Core --ntasks-per-node=9 -p development -t 02:00:00 slurm.sh splitbam.param


