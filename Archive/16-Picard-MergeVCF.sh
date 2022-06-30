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

############################################# Step 16: MERGE VCF ####################################################
# This Step is needed for merging VCF files where SNPs were called for a given interval
# !!!!!!!!!!!!!!Here I'm merging by locus, not by individuals!!!!!!!!!!!!!!!!!!!!!!!!!!
# If different VCF files have diferent sets of individuls this step will evoke ERROR!!!  

if [ -e mergevcf.param ]; then rm mergevcf.param; fi
while read line
do
        chr=`echo $line | cut -d' ' -f1`
        #PREF="-I  "
        #IN=""
        VCFF="VCFList_${chr}"
        #echo $BAMF
        if [ -e $VCFF ]; then rm $VCFF; fi

        for f in `ls $outDir/FinalVCF/*${chr}.rawSNP.vcf`
        do
                #IN+="${PREF}${f} "
                echo "$chr $f"
                echo $f >>$VCFF
        done    
        OFIL="${outDir}/MergeVCF/PHNATAcc_${chr}.vcf"
        echo "java -jar -Xmx64G $TACC_PICARD_DIR/build/libs/picard.jar MergeVcfs I=$VCFF R=$refDir/$ref \
        O=$OFIL TMP_DIR=$TMP" >>mergevcf.param
        #echo bcftools merge -l $VCFF -o $OFIL -O u --threads 24 >>mergevcf.param 
 
done <$CHRFIL

Core=`wc -l mergevcf.param  |cut -f1 -d ' '`
if (( $Core % 1 == 0)); then Node="$(($Core/1))";
        else  Node="$((($Core/1)+1))";
fi


## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J vcfmerge -N $Node -n $Core -p normal -t 48:00:00 slurm.sh mergevcf.param

