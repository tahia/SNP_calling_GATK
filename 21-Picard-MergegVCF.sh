############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/home/taslima/Data/DBs/PH/PhHAL #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/home/taslima/Data/PHNatAcc_SNP # output directory. It must be created before running the script

#TMP=/scratch/02786/taslima/data/phalli/Temp

CHRFIL=/home/taslima/Data/DBs/PH/PhHAL/PhalliiHAL_496_v2.0.chr
TMP=/home/taslima/Data/TMP

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.
#FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
#FH.2.06 1       AGBTB   8829.1.113057.GATCAG
#FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
#FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
#FH.7.06 1       YPGT    8577.7.104714.ACGATA

# load required module in TACC
#ml fastx_toolkit
#ml bwa
#ml picard
#ml samtools
#ml gatk/3.5.0
LC_ALL=C

############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

############################################# Step 21: MERGE gVCF ####################################################


if [ -e mergevcf.param ]; then rm mergevcf.param; fi

PREF="I="
IN=""
for f in `ls $outDir/CombVCF_AllSites_PHTRANS_V2/*_m80.recode.vcf`
do
    IN="${IN}${PREF}${f} "
    echo $f
done
    OFIL="${outDir}/CombVCF_AllSites_PHTRANS_V2/PHNatAcc_AllChr_SNP_m80.vcf"

echo "/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar -Xmx24G -Djava.io.tmpdir=$TMP /home/taslima/Tools/picard/2.11.0/picard.jar MergeVcfs \
    O=$OFIL $IN" >mergevcf.param


## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name

#sbatch -J vcfmerge -N 1 -n 1 -p development -t 02:00:00 slurm.sh mergevcfg.param



