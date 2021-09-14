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

################################################ Step 17: FILTER VCF ##############################################

if [ -e filterSNP.param ]; then rm filterSNP.param; fi
if [ -e filterSel.param ]; then rm filterSel.param; fi
for f in `ls $outDir/FinalVCF/*_merge_vcf.vcf`
do
    BASE=$(basename $f)
    NAME=${BASE%_merge_vcf.vcf} #change this if you did merge over genomic intervals
    OFIL2="${outDir}/FinalVCF/${NAME}.prefilterSNP.vcf"
    OFIL3="${outDir}/FinalVCF/${NAME}.postfilterSNP.vcf"
#### need to fix this --filterExpression \"(MQ >= 4) && ((MQ / (1.0 * DP)) > 0.10)\" --filterName \"HARD_TO_VALIDATE\"
    echo "java -jar -Xmx24G -XX:PermSize=1g -XX:MaxPermSize=2g \$TACC_GATK_DIR/GenomeAnalysisTK.jar -T VariantFiltration \
 --variant $f -R $refDir/$ref -o $OFIL2 --filterExpression \"QD < 2.0\" --filterName \"LowQD\" \
 --filterExpression \"MQ < 51.0\" --filterName \"low_MQ\" --filterExpression \"MQ > 61.0\" --filterName \"MQ_tooHigh\" \
 --filterExpression \"FS > 60.0\" --filterName \"HighStrandBias\" --filterExpression \"DP < 5\" --filterName \"low_COV\" \
--filterExpression \"DP > 100\" --filterName \"COV_TooHigh\" --filterExpression \"HaplotypeScore > 13.0\" --filterName \"failed_HaplotypeScore\" \
--filterExpression \"QUAL < 50.0\" --filterName \"Low_Quality\" --filterExpression \"MQRankSum < -12.5\" --filterName \"failed_MQRankSum\" \
--filterExpression \"ReadPosRankSum < -8.0\" --filterName \"failed_ReadPosRankSum\" --filterExpression \"SB > -10.0\" \
--filterName \"failed_StrandBias\" \
--genotypeFilterExpression \"GQ < 25\" --genotypeFilterName \"GQ_LT_25\" " >>filterSNP.param
    #echo "grep \"PASS\" $OFIL2 | grep -v \"GQ_LT_25\" | grep -v \"^##\" >$OFIL3 " >grepSNPfilter.param
    echo "java -jar -Xmx2G -XX:PermSize=1g -XX:MaxPermSize=2g /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T  SelectVariants \
--variant $OFIL2 -R $refDir/$ref --excludeFiltered -o $OFIL3" >>filterSel.param
done

Core=`wc -l filterSNP.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi


## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J prefiltersnp -N $Node -n $Core -p normal -t 24:00:00 slurm.sh filterSNP.param
