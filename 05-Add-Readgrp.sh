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

########################## step 5: RUN PICARD ADD READ GRP & SORT COORD ###########################

# Change the field as per your sample name if needed
if [ -e picard-sort2.param ]; then rm picard-sort2.param; fi
for f in `ls $outDir/MapFiltered/*_Q20.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_Q20.bam}
    OFIL="${outDir}/AddGrpSort/${NAME}_RGP.bam"
    SAM=`echo $NAME | awk -F"_" '{print $1}'`
    LIB="lib1"
    #java -jar -Xmx1G /home1/apps/intel17/picard/2.11.0/build/libs/picard.jar AddOrReplaceReadGroups
    echo "java -Xmx6G -jar \$TACC_PICARD_DIR/build/libs/picard.jar AddOrReplaceReadGroups OUTPUT=$OFIL INPUT=$f SORT_ORDER=coordinate RGID=$SAM RGLB=$SAM RGSM=$SAM RGPL=illumina RGPU=none VALIDATION_STRINGENCY=LENIENT TMP_DIR=$TMP" >> \
        picard-sort2.param
done

# Now Run the job.To be safe side assign for 4 hrs.
Core=`wc -l picard-sort2.param |cut -f1 -d ' '`
if (( $Core % 8 == 0)); then Node="$(($Core/8))";
        else  Node="$((($Core/8)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J picardsort -N $Node -n $Core --ntasks-per-node=8 -p normal -t 48:00:00 slurm.sh picard-sort2.param

