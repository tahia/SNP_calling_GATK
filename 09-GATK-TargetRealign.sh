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

##################################### Step 9: GATK RealignerTargetCreator ###########################################


if [ -e target.param ]; then rm target.param; fi
if [ -e realgn.param ]; then rm realgn.param; fi
for f in `ls $outDir/MarkDup/*_dedup.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_dedup.bam}
    OFIL="${outDir}/AllGATK/${NAME}.reAligned.bam"
    OBAM="${outDir}/AllGATK/${NAME}.reAligned.bai"
    IV="${outDir}/AllGATK/${NAME}.output.intervals"

    echo "java -jar -Xmx6G -XX:PermSize=1g -XX:MaxPermSize=1g \$TACC_GATK_DIR/GenomeAnalysisTK.jar -T RealignerTargetCreator \
	-I $f -R $refDir/$ref -o $IV --filter_bases_not_stored" >>target.param
    echo "java -jar -Xmx6G -XX:PermSize=1g -XX:MaxPermSize=1g \$TACC_GATK_DIR/GenomeAnalysisTK.jar -T IndelRealigner \
	-I $f -R $refDir/$ref -targetIntervals $IV -o $OFIL --filter_mismatching_base_and_quals --filter_bases_not_stored" >>realgn.param 
done

# Now Run the job.To be safe side assign for 2 hrs.
Core=`wc -l target.param  |cut -f1 -d ' '`
if (( $Core % 4 == 0)); then Node="$(($Core/4))";
        else  Node="$((($Core/4)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J target -N $Node -n $Core -p development -t 02:00:00 --ntasks-per-node=4 slurm.sh target.param

