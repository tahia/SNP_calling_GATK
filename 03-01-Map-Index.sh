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
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis # output directory. It must be created before running the script
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK_NATACC/JGI_DL_78_Design.tab # Full path of meta file
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

############### Step 3-01: RUN MAP Index ########################################

#before maping do index for bwa mem, samtool index and picard dict.If you have all three index in your reference
# directory , then ignore this step and run 3-02

if [ -e index.param ]; then rm index.param; fi 

echo "bwa index $refDir/$ref" >>index.param
echo "java -jar -Xmx24G /home1/apps/intel17/picard/2.11.0/build/libs/picard.jar CreateSequenceDictionary R=$refDir/$ref O=$refDir/${ref%.fa}.dict " >>\
    index.param
echo "samtools faidx $refDir/$ref" >>index.param

sbatch -J index -N 1 -n 3 -p development --ntasks-per-node=3 -t 02:00:00 slurm.sh index.param


