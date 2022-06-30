############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling

refDir=/home/taslima/Data/DBs/PH/PhHAL #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/home/taslima/Data/PHNatAcc_SNP # output directory. It must be created before running the script
# Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.
#FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
#FH.2.06 1       AGBTB   8829.1.113057.GATCAG
#FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
#FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
#FH.7.06 1       YPGT    8577.7.104714.ACGATA

# load required module in TACC
#ml intel/17.0.4
#ml fastx_toolkit
#ml bwa
#ml picard
#ml samtools
#ml gatk/3.8.0
LC_ALL=C

############### Step 3-01: RUN MAP Index ########################################

#before maping do index for bwa mem, samtool index and picard dict.If you have all three index in your reference
# directory , then ignore this step and run 3-02

if [ -e index.param ]; then rm index.param; fi 

echo "bwa index $refDir/$ref" >>index.param
echo "java -jar -Xmx24G /home/taslima/Tools/picard/2.11.0/picard.jar CreateSequenceDictionary R=$refDir/$ref O=$refDir/${ref%.fa}.dict " >>\
    index.param
echo "samtools faidx $refDir/$ref" >>index.param

#sbatch -J index -N 1 -n 3 -p development --ntasks-per-node=3 -t 02:00:00 slurm.sh index.param


