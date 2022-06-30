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
outDir=/scratch/02786/taslima/data/PHNATAcc # output directory. It must be created before running the script
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK_NATACC/JGI_DL_78_Design.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp


LOG="logs"

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.
#POI	1079226	PanhalPOI38_FD	Files: 7	Size: 130GB
#DOF	1079234	PanhalDOF11_FD	Files: 3	Size: 19GB
#SEV	1021766	Panhalsequencing_39_FD	Files: 2	Size: 22GB
#PDK	1043188	Panhalsequencing_44_FD	Files: 3	Size: 26GB


# load required module in TACC
ml intel/17.0.4
ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.8.0
LC_ALL=C

#################################### Step 1: Rename ############################################

# Now rename all the files acording to meta deta

if [ -e rename.param ]; then rm rename.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

while read line
do
    SAMP=`echo $line | cut -d' ' -f1`
    fol=`echo $line |  cut -d' ' -f3`
    #f="${outDir}/V2/${fol}/Sequence/Raw_Data/*.fastq"
    f="${outDir}/V3/${fol}/Raw_Data/*.fastq"
    OFIL="${outDir}/Analysis/V3/Renamed/${SAMP}.fastq"
    OLOG="${LOG}/${SAMP}.log"
    echo $f
    echo "cat $f > $OFIL 2> $OLOG" >> \
       rename.param
done < $met

# Now count the line number of the file and copy will not take more that one hr
Core=`wc -l rename.param |cut -f1 -d ' '`
if (( $Core % 26 == 0)); then Node="$(($Core/26))";
        else  Node="$((($Core/26)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rename -N $Node -n $Core --ntasks-per-node=26 -p normal -t 06:00:00 slurm.sh rename.param

