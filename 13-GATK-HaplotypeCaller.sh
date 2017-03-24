############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=Phallii_308_v2.0.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/phalli/Phal_RILSeq_v2 # output directory. It must be created before running the script
met=/scratch/02786/taslima/data/phalli/RIL_meta.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.
#FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
#FH.2.06 1       AGBTB   8829.1.113057.GATCAG
#FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
#FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
#FH.7.06 1       YPGT    8577.7.104714.ACGATA

# load required module in TACC
ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.5.0
LC_ALL=C

############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

########################################## Step 13: RUN GATK to call raw CALL SNP ################################################

# HaplotypeCaller(HC) is better in terms of miscall of heterozygosity compare to UnifiedGenotyper(UG)

if [ -e rawSNPg.param ]; then rm rawSNPg.param; fi
for f in `ls $outDir/AllGATK/*_GATK.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_GATK.bam}
    OFIL1="${outDir}/FinalVCF/${NAME}.rawSNP.g.vcf"

    echo "java -jar -Xmx6G -XX:PermSize=1g -XX:MaxPermSize=1g \$TACC_GATK_DIR/GenomeAnalysisTK.jar -T HaplotypeCaller \
 --emitRefConfidence GVCF -I $f -R $refDir/$ref -o $OFIL1 --alleles $refDir/$vcf -out_mode EMIT_ALL_CONFIDENT_SITES \
 -L $refDir/$intervals -rf BadCigar --logging_level ERROR -A QualByDepth -A RMSMappingQuality -A FisherStrand \
  -A Coverage -A HaplotypeScore -A MappingQualityRankSumTest -A ReadPosRankSumTest -A MappingQualityZero" >>rawSNPg.param
done

Core=`wc -l rawSNPg.param  |cut -f1 -d ' '`
if (( $Core % 4 == 0)); then Node="$(($Core/4))";
        else  Node="$((($Core/4)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp --mail-user=taslima@utexas.edu -N $Node -n $Core -p development -t 02:00:00 slurm.sh rawSNPg.param


