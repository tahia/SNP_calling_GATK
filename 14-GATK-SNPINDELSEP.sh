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

if [ -e SelSNP.param ]; then rm SelSNP.param; fi
if [ -e SelINDEL.param ]; then rm SelINDEL.param; fi
for f in `ls $outDir/FinalVCF/*rawVAR.vcf`
do
    BASE=$(basename $f)
    NAME=${BASE%.rawVAR.vcf}
    OFIL2="${outDir}/FinalVCF/${NAME}.rawSNP.vcf"
    OFIL3="${outDir}/FinalVCF/${NAME}.rawINDEL.vcf"
    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants \
 --variant $f -R $refDir/$ref -o $OFIL2 -selectType SNP  " >>SelSNP.param

    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants \
 --variant $f -R $refDir/$ref -o $OFIL3 -selectType INDEL  " >>SelINDEL.param
     
done


##### SNP FILTER


split -l 522 --additional-suffix=SelSNP.param SelSNP.param 

#
Core=`wc -l xaaSelSNP.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 02:00:00 --ntasks-per-node=60 slurm.sh xaaSelSNP.param


#
Core=`wc -l xabSelSNP.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 02:00:00 --ntasks-per-node=60 slurm.sh xabSelSNP.param

### INDEL

split -l 522 --additional-suffix=SelINDEL.param SelINDEL.param 

#
Core=`wc -l xaaSelINDEL.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 02:00:00 --ntasks-per-node=60 slurm.sh xaaSelINDEL.param


#
Core=`wc -l xabSelINDEL.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 02:00:00 --ntasks-per-node=60 slurm.sh xabSelINDEL.param

