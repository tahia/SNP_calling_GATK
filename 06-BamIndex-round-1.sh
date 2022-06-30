############################################# Head of all Scripts ####################################
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


######################################### Step 6: RUN BAM INDEX : Round 1 ##########################################

if [ -e bam-index-1.param ]; then rm bam-index-1.param; fi
for f in `ls $outDir/AddGrpSort/*_RGP.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%.bam}
    OFIL="${outDir}/AddGrpSort/${NAME}.bai"

    echo "java -jar -Xmx4G  \$TACC_PICARD_DIR/build/libs/picard.jar BuildBamIndex OUTPUT=$OFIL INPUT=$f VALIDATION_STRINGENCY=LENIENT" >>bam-index-1.param 
done

# Now Run the job.To be safe side assign for 2 hrs.
Core=`wc -l bam-index-1.param  |cut -f1 -d ' '`
if (( $Core % 17 == 0)); then Node="$(($Core/17))";
        else  Node="$((($Core/17)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J bamindex -N $Node -n $Core --ntasks-per-node=17 -p normal -t 12:00:00 slurm.sh bam-index-1.param 


