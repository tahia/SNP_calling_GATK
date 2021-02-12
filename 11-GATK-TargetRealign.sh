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
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V3 # output directory. It must be created before running the script
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

##################################### Step 11: GATK RealignerTargetCreator ###########################################

LOG="logs/"
if [ -e target.param ]; then rm target.param; fi
if [ -e realgn.param ]; then rm realgn.param; fi
for f in `ls $outDir/BAMSPLIT/*.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%.bam}
    OFIL="${outDir}/AllGATK/${NAME}.reAligned.bam"
    OBAM="${outDir}/AllGATK/${NAME}.reAligned.bai"
    IV="${outDir}/AllGATK/${NAME}.output.intervals"
    OLOT="${LOG}${NAME}_target.log"
    OLOR="${LOG}${NAME}_realign.log"

    echo "java -jar -Xmx4G -XX:PermSize=1g -XX:MaxPermSize=1g /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T RealignerTargetCreator \
	-I $f -R $refDir/$ref -o $IV --filter_bases_not_stored 2>$OLOT" >>target.param
    echo "java -jar -Xmx4G -XX:PermSize=1g -XX:MaxPermSize=1g /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T IndelRealigner \
	-I $f -R $refDir/$ref -targetIntervals $IV -o $OFIL --filter_bases_not_stored 2>$OLOR" >>realgn.param 
done

#--filter_mismatching_base_and_quals
# Now Run the job.To be safe side assign for 12 hrs.
#Core=`wc -l target.param  |cut -f1 -d ' '`
#if (( $Core % 16 == 0)); then Node="$(($Core/16))";
#        else  Node="$((($Core/16)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J target -N $Node -n $Core -p normal -t 24:00:00 --ntasks-per-node=16 slurm.sh target.param

#run it into two slot
#wc -l bam-index-FB.param 
#5085 bam-index-FB.param
#split -l 414 --additional-suffix=target.param target.param 

#
#Core=`wc -l xaatarget.param  |cut -f1 -d ' '`
#if (( $Core % 16 == 0)); then Node="$(($Core/16))";
#        else  Node="$((($Core/16)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J target -N $Node -n $Core -p normal -t 24:00:00 --ntasks-per-node=16 slurm.sh xaatarget.param


#
#Core=`wc -l xabtarget.param  |cut -f1 -d ' '`
#if (( $Core % 16 == 0)); then Node="$(($Core/16))";
#        else  Node="$((($Core/16)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J target -N $Node -n $Core -p normal -t 24:00:00 --ntasks-per-node=16 slurm.sh xabtarget.param

