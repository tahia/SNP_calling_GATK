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

LOGD="logs"
############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

################################################ Step 15: FILTER VCF ##############################################

if [ -e filterSNPr2.param ]; then rm filterSNPr2.param; fi
if [ -e filterSelr2.param ]; then rm filterSelr2.param; fi

for f in `ls $outDir/CombVCF_AllSites/*_Comb.SNP.vcf`
do
    #echo $f
    BASE=$(basename $f)
    NAME=${BASE%_Comb.SNP.vcf}
    OFIL2="${outDir}/CombVCF_AllSites/${NAME}.filterSNP.vcf"
    OFIL3="${outDir}/CombVCF_AllSites/${NAME}.postfilterSNP.vcf"
    LOGO="${LOGD}/${NAME}.log"
    LOGE="${LOGD}/${NAME}.err"

   
#'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0'
    echo "/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar -Xmx6G -Djava.io.tmpdir=$TMP /home/taslima/Tools/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration \
 --variant $f -R $refDir/$ref -o $OFIL2\
 --filterExpression 'QD < 2.0 || FS > 60.0  ||  MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0' --filterName \"basic_snp_filter\"  \
-G_filter \"DP < 3\"  -G_filterName \"low_COV\" -log $LOGO 2>$LOGE" >>filterSNPr2.param

#-G_filter \"DP < 3\"  -G_filterName \"low_COV\" 
    echo "/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar -Xmx6G -Djava.io.tmpdir=$TMP /home/taslima/Tools/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T  SelectVariants \
 --variant $OFIL2 -R $refDir/$ref --excludeFiltered --setFilteredGtToNocall -o $OFIL3" >>filterSelr2.param

done


#
#Core=`wc -l filterSNPr2.param  |cut -f1 -d ' '`
#if (( $Core % 1 == 0)); then Node="$(($Core/1))";
#        else  Node="$((($Core/1)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J FilterSNP -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=1 slurm.sh filterSNPr2.param
