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

############################################# Step 14-01: Filter gVCF ####################################################

# It is only an additional script to filter excess heterozygocity. Look into the perl script and use this step only if you need that filter

if [ -e perlfilter.param ]; then rm perlfilter.param; fi
for f in `ls $outDir/FinalVCF/*.rawSNP.g.vcf`
do
    BASE=$(basename $f)
    NAME=${BASE%.rawSNP.g.vcf}
    OFIL="${outDir}/FinalVCF/${NAME}.filter.g.vcf"

# Change the path of the perl file name "gVCF_parser.pl" in your system. use the absolute path.
# Replace /work/***/taslima/bin/Scot_script to your/absolute/path

    echo "perl /work/***/taslima/bin/Scot_script/gVCF_parser.pl -i $f -o $OFIL -d 5" >>perlfilter.param
done

Core=`wc -l rawSNPg.param  |cut -f1 -d ' '`
if (( $Core % 16 == 0)); then Node="$(($Core/16))";
        else  Node="$((($Core/16)+1))";
fi

# For each sample it only take few minutes. Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name

sbatch -J perlfilter  -N $Node -n $Core -p development -t 02:00:00 slurm.sh perlfilter.param

