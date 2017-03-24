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

############################################# Step 14: MERGE VCF ####################################################

# This merge vcf is for the output of Unified genotyper

if [ -e mergevcf.param ]; then rm mergevcf.param; fi

PREF="--variant "
IN=""
for f in `ls $outDir/FinalVCF/*.rawSNP.vcf`
do
    IN+="${PREF}${f} "
done
    OFIL="${outDir}/FinalVCF/AllRIL_merge_vcf.vcf"

echo "java -jar -Xmx24G \$TACC_GATK_DIR/GenomeAnalysisTK.jar -T CombineVariants -R $refDir/$ref -o $OFIL $IN -genotypeMergeOptions REQUIRE_UNIQUE" >mergevcf.param



## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J vcfmerge -N 1 -n 1 -p development -t 02:00:00 slurm.sh mergevcf.param

