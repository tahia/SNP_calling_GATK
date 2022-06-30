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

########################################## Step 13: RUN GATK to call raw CALL SNP ################################################

# HaplotypeCaller(HC) is better in terms of miscall of heterozygosity compare to UnifiedGenotyper(UG)

if [ -e rawSNP2.param ]; then rm rawSNP2.param; fi
for f in `ls $outDir/AllGATK/*_GATK.bam`
do
    BASE=$(basename $f)
    NAME=${BASE%_GATK.bam}
    OFIL1="${outDir}/FinalVCF/${NAME}.rawVAR.vcf"

    echo "java -jar -Xmx4G /home1/02786/taslima/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T HaplotypeCaller \
 -I $f -R $refDir/$ref -o $OFIL1 -nct 4 \
 -out_mode EMIT_ALL_CONFIDENT_SITES \
 -variant_index_type LINEAR -variant_index_parameter 128000 \
 -rf BadCigar --logging_level ERROR -A QualByDepth -A RMSMappingQuality -A FisherStrand \
  -A Coverage -A HaplotypeScore -A MappingQualityRankSumTest -A ReadPosRankSumTest -A MappingQualityZero" >>rawSNP2.param
done



split -l 522 --additional-suffix=rawSNP2.param rawSNP2.param 

#
Core=`wc -l xaarawSNP2.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=12 slurm.sh xaarawSNP2.param


#
Core=`wc -l xabrawSNP2.param  |cut -f1 -d ' '`
if (( $Core % 12 == 0)); then Node="$(($Core/12))";
        else  Node="$((($Core/12)+1))";
fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
sbatch -J rawsnp -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=12 slurm.sh xabrawSNP2.param

