############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V7 # output directory. It must be created before running the script
met=/scratch/02786/taslima/data/phalli/RIL_meta.tab # Full path of meta file
TMP=/scratch/02786/taslima/data/phalli/Temp


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


####################################### Step 7: RUN MARK DUP ##########################################################

if [ -e markdup.param ]; then rm markdup.param; fi
if [ -e bam-index-2.param ]; then rm bam-index-2.param; fi
for f in `ls $outDir/AddGrpSort/*_RGP.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_RGP.bam}
    OFIL="${outDir}/MarkDup/${NAME}_dedup.bam"
    OBAM="${outDir}/MarkDup/${NAME}_dedup.bai"
    MT="${outDir}/MarkDup/${NAME}.duplicateMetricsFile.dat"

    echo "java -jar -Xmx8G  \$TACC_PICARD_DIR/build/libs/picard.jar MarkDuplicates OUTPUT=$OFIL INPUT=$f METRICS_FILE=$MT \
	VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true SORTING_COLLECTION_SIZE_RATIO=0.05 REMOVE_DUPLICATES=true TMP_DIR=$TMP \
	 MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=200 MAX_RECORDS_IN_RAM=10000000" >>markdup.param
    echo "java -jar -Xmx8G  \$TACC_PICARD_DIR/build/libs/picard.jar  BuildBamIndex OUTPUT=$OBAM INPUT=$OFIL VALIDATION_STRINGENCY=LENIENT" >>bam-index-2.param
done

# Now Run the job.To be safe side assign for 2 hrs.
Core=`wc -l markdup.param  |cut -f1 -d ' '`
if (( $Core % 8 == 0)); then Node="$(($Core/8))";
        else  Node="$((($Core/8)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J markdup -N $Node -n $Core --ntasks-per-node=16 -p normal -t 24:00:00 slurm.sh markdup.param

