############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/stampede2/dbs/PH #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V7 # output directory. It must be created before running the script

TMP=/scratch/02786/taslima/data/phalli/Temp

CHRFIL=/work/02786/taslima/stampede2/dbs/PH/PhalliiHAL_496_v2.0.chr

# load required module in TACC
ml intel/17.0.4
ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.8.0
LC_ALL=C

############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

########################################## Step 15: RUN BSQR ################################################

if [ -e baserecal.param ]; then rm baserecal.param; fi
if [ -e baserecalpost.param ]; then rm baserecalpost.param; fi
if [ -e baserecalbam.param ]; then rm baserecalbam.param; fi
for f in `ls $outDir/FinalVCF/*.filterSNP.vcf`
do
    BASE=$(basename $f)
    NAME=${BASE%.filterSNP.vcf}
    f2="${outDir}/FinalVCF/${NAME}.filterIND.vcf"
    OFIL2="${outDir}/FinalVCF/${NAME}.BSQR.table"
    OFIL3="${outDir}/FinalVCF/${NAME}.BSQR.post.table"
    OFIL4="${outDir}/FinalVCF/${NAME}_BSQR.bam"
    IBAM="${outDir}/AllGATK/${NAME}_GATK.bam"
    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T BaseRecalibrator \
 -I $IBAM -knownSites $f -knownSites $f2 -R $refDir/$ref -o $OFIL2 -nct 4 " >>baserecal.param

   echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T BaseRecalibrator \
 -I $IBAM -knownSites $f -knownSites $f2 -R $refDir/$ref -BQSR $OFIL2-o $OFIL3 -nct 4 " >>baserecalpost.param 

    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T PrintReads \
    -I $IBAM -R $refDir/$ref -BQSR $OFIL2 -o $OFIL4 -nct 4" >>baserecalbam.param
done


split -l 522 --additional-suffix=baserecal.param baserecal.param 

#
Core=`wc -l xaabaserecal.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J BSQRtab -N $Node -n $Core -p normal -t 08:00:00 --ntasks-per-node=12 slurm.sh xaabaserecal.param


#
Core=`wc -l xabbaserecal.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J BSQRtab -N $Node -n $Core -p normal -t 08:00:00 --ntasks-per-node=12 slurm.sh xabbaserecal.param

