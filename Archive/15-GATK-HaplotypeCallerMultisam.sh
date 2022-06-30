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
refDir=/work/02786/taslima/stampede2/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/RIL_PHAL_2019 # output directory. It must be created before running the script
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/JGI_DL_78_Design.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp
CHRFIL=/work/02786/taslima/stampede2/dbs/PH/PhalliiHAL_496_v2.0.chr #name of each chromosome one in each line

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

########################################## Step 15: RUN GATK to call raw CALL SNP ################################################

# HaplotypeCaller(HC) is better in terms of miscall of heterozygosity compare to UnifiedGenotyper(UG)
# For population use this script to call SNP for more that one individuals

if [ -e rawSNPg.param ]; then rm rawSNPg.param; fi
while read line
do
    for f in `ls $outDir/AllGATK/*_${line}_GATK.bam`
	do
		IN+="${PREF}${f} "
                echo $f
	done 
        OFIL1="${outDir}/FinalVCF/${line}.rawSNP.vcf"

        echo "java -jar -Xmx4G -XX:PermSize=1g -XX:MaxPermSize=1g /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T HaplotypeCaller \
        -I $f -R $refDir/$ref -o $OFIL1 -nct 20 \
        -out_mode EMIT_ALL_CONFIDENT_SITES \
        -rf BadCigar --logging_level ERROR -A QualByDepth -A RMSMappingQuality -A FisherStrand \
        -A Coverage -A HaplotypeScore -A MappingQualityRankSumTest -A ReadPosRankSumTest -A MappingQualityZero" >>rawSNPg.param
done <$CHRFIL

#--alleles $refDir/$vcf \
# -L $refDir/$intervals \
 #--emitRefConfidence GVCF 
Core=`wc -l rawSNPg.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp --mail-user=taslima@utexas.edu -N $Node -n $Core -p normal -t 48:00:00 slurm.sh rawSNPg.param


