############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/stampede2/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V7 # output directory. It must be created before running the script

TMP=/scratch/02786/taslima/data/phalli/Temp

CHRFIL=/work/02786/taslima/stampede2/dbs/PH/PhalliiHAL_496_v2.0.chr

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

################################################ Step 15: FILTER VCF ##############################################

if [ -e filterSNP.param ]; then rm filterSNP.param; fi
if [ -e filterIND.param ]; then rm filterIND.param; fi
for f in `ls $outDir/FinalVCF/*.rawSNP.vcf`
do
    BASE=$(basename $f)
    NAME=${BASE%.rawSNP.vcf}
    IND="${outDir}/FinalVCF/${NAME}.rawINDEL.vcf"
    OFIL2="${outDir}/FinalVCF/${NAME}.filterSNP.vcf"
    OFIL3="${outDir}/FinalVCF/${NAME}.filterIND.vcf"
#--filterExpression 'QD < 2.0 || ReadPosRankSum < -8.0|| MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0
    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration \
 --variant $f -R $refDir/$ref -o $OFIL2\
 --filterExpression 'QD < 2.0 || ReadPosRankSum < -8.0|| MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0' --filterName \"basic_snp_filter\" " >>filterSNP.param

#--filterExpression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0'
      echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration \
 --variant $IND -R $refDir/$ref -o $OFIL3\
 --filterExpression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0 ' --filterName \"basic_indel_filter\"" >>filterIND.param  
done



split -l 522 --additional-suffix=filterSNP.param filterSNP.param 

#
Core=`wc -l xaafilterSNP.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J FilterSNP -N $Node -n $Core -p normal -t 06:00:00 --ntasks-per-node=12 slurm.sh xaafilterSNP.param


#
Core=`wc -l xabfilterSNP.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J FilterSNP -N $Node -n $Core -p normal -t 06:00:00 --ntasks-per-node=12 slurm.sh xabfilterSNP.param


split -l 522 --additional-suffix=filterIND.param filterIND.param

#
Core=`wc -l xaafilterIND.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J FilterIND -N $Node -n $Core -p normal -t 06:00:00 --ntasks-per-node=12 slurm.sh xaafilterIND.param


#
Core=`wc -l xabfilterIND.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J FilterIND -N $Node -n $Core -p normal -t 06:00:00 --ntasks-per-node=12 slurm.sh xabfilterIND.param

