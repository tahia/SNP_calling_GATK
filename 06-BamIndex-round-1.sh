##########################################################################################################################
# This script is a part of genome-wide SNP Calling Pipeline for Plants by implementing Genome Analysis Toolkit (GATK)    #
# For further information about GATK please visit : https://gatk.broadinstitute.org/hc/en-us                             #
# Detail description of this pipe can be found in github: https://github.com/tahia/SNP_calling_GATK                      #
# Author : Taslima Haque                                                                                                 #
# Last modified: 12th Feb,2021                                                                                           #
# Please send your query to the author at: taslima@utexas.edu or tahiadu@gmail.com                                       #
##########################################################################################################################



############################################# Head of all Scripts ####################################
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


######################################### Step 6: RUN BAM INDEX : Round 1 ##########################################

if [ -e bam-index-1.param ]; then rm bam-index-1.param; fi
for f in `ls $outDir/AddGrpSort_v2/*_RGP.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%.bam}
    OFIL="${outDir}/AddGrpSort_v2/${NAME}.bai"

    echo "java -jar -Xmx24G  \$TACC_PICARD_DIR/build/libs/picard.jar BuildBamIndex OUTPUT=$OFIL INPUT=$f VALIDATION_STRINGENCY=LENIENT" >>bam-index-1.param 
done

# Now Run the job.To be safe side assign for 2 hrs.
Core=`wc -l bam-index-1.param  |cut -f1 -d ' '`
if (( $Core % 17 == 0)); then Node="$(($Core/17))";
        else  Node="$((($Core/17)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J bamindex -N $Node -n $Core --ntasks-per-node=17 -p normal -t 12:00:00 slurm.sh bam-index-1.param 


