############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/home/taslima/Data/DBs/PH/PhHAL #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/home/taslima/Data/PHNatAcc_SNP # output directory. It must be created before running the script

TMP=/home/taslima/Data/TMP

CHRFIL=/home/taslima/Data/DBs/PH/PhHAL/PhalliiHAL_496_v2.0.chr
CHRLN=/home/taslima/Data/DBs/PH/PhHAL/PhalliiHAL_496_v2.chr.length

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

################################################ Step 20: FILTER VCFTools ##############################################

if [ -e vcftools.param ]; then rm vcftools.param; fi
for f in `ls $outDir/CombVCF_AllSites/*postfilterSNP.vcf`
do
    #echo $f
    BASE=$(basename $f)
    NAME=${BASE%.postfilterSNP.vcf}
    OFIL2="${outDir}/CombVCF_AllSites/${NAME}_NonVar"
    LOGO="${LOGD}/${NAME}.log"
    LOGE="${LOGD}/${NAME}.err"
 
    echo "vcftools --vcf $f --max-alleles 1 --min-alleles 1 --max-maf 0  --max-missing 0.80 --min-meanDP 20 --minQ 30 --recode --recode-INFO-all --out $OFIL2" >>vcftools.param

done


#
#Core=`wc -l vcftools.param  |cut -f1 -d ' '`
#if (( $Core % 1 == 0)); then Node="$(($Core/1))";
#        else  Node="$((($Core/1)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J FilterSNP -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=1 slurm.sh vcftools.param
