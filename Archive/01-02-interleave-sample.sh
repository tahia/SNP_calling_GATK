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
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V3 # output directory. It must be created before running the scrpt
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/JGI_DL_78_Design.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp
LOG="logs"

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

#################################### Step 1: Interleaf ############################################

# Now rename all the files acording to meta deta

if [ -e interleave.param ]; then rm interleave.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

SCRIPT="/work/02786/taslima/stampede2/tools/bbmap/reformat.sh"

#for f in `ls $outDir/Renamed/*fastq`
for f in `ls $outDir/*[A-Z].fastq`
do
    BASE=$(basename $f)
    NAME=${BASE%.fastq}
    OFIL1="${outDir}/Renamed/${NAME}_R1.fastq"   
    OFIL2="${outDir}/Renamed/${NAME}_R2.fastq"
    OLOG="${LOG}${NAME}.log"
    echo "$SCRIPT -Xmx24G in=$f out=$OFIL1 out2=$OFIL2 >$OLOG " >> interleave.param
done

# Now count the line number of the file and copy will not take more that one hr

Core=`wc -l interleave.param |cut -f1 -d ' '`
if (( $Core % 10 == 0)); then Node="$(($Core/10))";
        else  Node="$((($Core/10)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J interleave -N $Node -n $Core --ntasks-per-node=2 -p development -t 02:00:00 slurm.sh interleave.param

