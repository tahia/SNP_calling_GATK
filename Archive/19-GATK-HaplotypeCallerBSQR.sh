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

########################################## Step 19: RUN GATK to call raw CALL SNP for single sample

# HaplotypeCaller(HC) is better in terms of miscall of heterozygosity compare to UnifiedGenotyper(UG)

if [ -e filSNPg.param ]; then rm filSNPg.param; fi
for f in `ls $outDir/AllGATK/*_BSQR.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_BSQR.bam}
    OFIL1="${outDir}/FinalVCF/${NAME}.BSQRSNP.vcf"

    echo "java -jar -Xmx4G -XX:PermSize=1g -XX:MaxPermSize=1g /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T HaplotypeCaller \
 -I $f -R $refDir/$ref -o $OFIL1 -nct 4 \
 -out_mode EMIT_ALL_CONFIDENT_SITES \
 --emitRefConfidence GVCF \
 -rf BadCigar --logging_level ERROR -A QualByDepth -A RMSMappingQuality -A FisherStrand \
  -A Coverage -A HaplotypeScore -A MappingQualityRankSumTest -A ReadPosRankSumTest -A MappingQualityZero" >>filSNPg.param
done

#--alleles $refDir/$vcf \
# -L $refDir/$intervals \
 #--emitRefConfidence GVCF
Core=`wc -l filSNPg.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J BSQRsnp --mail-user=taslima@utexas.edu -N $Node -n $Core -p normal -t 48:00:00 slurm.sh filSNPg.param


#split -l 495 --additional-suffix=rawSNPg.param filSNPg.param

#
#Core=`wc -l xaafilSNPg.param  |cut -f1 -d ' '`
#if (( $Core % 12 == 0)); then Node="$(($Core/12))";
#        else  Node="$((($Core/12)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J BSQRsnp -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=12 slurm.sh xaafilSNPg.param


#
#Core=`wc -l xabfilSNPg.param  |cut -f1 -d ' '`
#if (( $Core % 12 == 0)); then Node="$(($Core/12))";
#        else  Node="$((($Core/12)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J BSQRsnp -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=12 slurm.sh xabfilSNPg.param
