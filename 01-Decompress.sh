############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=Phallii_308_v2.0.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/V7/MEXICAN # output directory. It must be created before running the script
met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/RIL_meta.tab # Full path of meta file
ID=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/ID_RIL_v1_uniq
TMP=/scratch/02786/taslima/data/phalli/Temp
LOG="logs"

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

#################################### Step 1-1: Decomp ############################################

if [ -e decomp.param ]; then rm decomp.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

for f in `ls outDir/raw/*.bz2`
do
    BASE=$(basename $f)
    NAME=${BASE%.bz2}
    OFIL="${outDir}/${NAME}"
    OLOG="${LOG}/${NAME}.log"
    echo "bunzip2 $f --stdout > $OFIL 2> $OLOG" >> decomp.param
done

# Now count the line number of the file and copy will not take more that one hr
Core=`wc -l decomp.param |cut -f1 -d ' '`
if (( $Core % 30 == 0)); then Node="$(($Core/30))";
        else  Node="$((($Core/30)+1))";
fi

#echo $Node
## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rename -N $Node -n $Core --ntasks-per-node=30 -p normal -t 06:00:00 slurm.sh decomp.param

