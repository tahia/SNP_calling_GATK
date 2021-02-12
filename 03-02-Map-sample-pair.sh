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

############### Step 3-2: RUN MAP ########################################


if [ -e bwa-mem.param ]; then rm bwa-mem.param; fi
for f in `ls $outDir/QualFiltered_v2/*_R1.fastq`
do
    BASE=$(basename $f)
    NAME=${BASE%_R1.fastq}
    OFIL="${outDir}/Mapped_v3/${NAME}.sam"
    ff=${f%_R1.fastq}_R2.fastq
    #echo "$ff"
    echo "bwa mem -t 32 $refDir/$ref $f $ff > $OFIL" >> \
        bwa-mem.param
done

# Now Run the job.To be same side assign for 12 hrs.
Core=`wc -l bwa-mem.param |cut -f1 -d ' '`
if (( $Core % 8 == 0)); then Node="$(($Core/8))";
        else  Node="$((($Core/8)+1))";
fi

echo "$Node $Core"
## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J map -N $Node -n $Core -p normal -t 32:00:00 --ntasks-per-node=8 slurm.sh bwa-mem.param

