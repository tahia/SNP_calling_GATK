############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/home/taslima/Data/DBs/PH/PhHAL #Reference directory where the reference genome file will be
ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file
outDir=/home/taslima/Data/PHNatAcc_SNP # output directory. It must be created before running the script

TMP=/home/taslima/Data/TMP

CHRFIL=/home/taslima/Data/DBs/PH/PhHAL/PhalliiHAL_496_v2.0.chr
CHRLN=/home/taslima/Data/DBs/PH/PhHAL/PhalliiHAL_496_v2.chr.length
# load required module in TACC
#ml intel/17.0.4
#ml fastx_toolkit
#ml bwa
#ml picard
#ml samtools
#ml gatk/3.8.0
LC_ALL=C

############### !!!!!! Make sure you are using the same version of GATK for the total pipe !!!! #####################

########################################## Step 17: RUN GATK GenotypeGCVF ################################################


if [ -e genogvcf.param ]; then rm genogvcf.param; fi

while read line
    do
        chr=`echo $line | cut -d' ' -f1`
        length=`echo $line | cut -d' ' -f2`
    	chrlist="${outDir}/FinalVCF/${chr}.GVCFsList"
        echo  $chrlist
    	`ls $outDir/FinalVCF/*$chr.BSQR.gvcf >$chrlist`
     	PREF="-V  "
     	IN=""
     	for f in `ls $outDir/FinalVCF/*$chr.BSQR.gvcf`
        do
		IN="${IN}${PREF}${f} "
                #echo $IN
        done 

    #echo "$IN"
    OFIL1="${outDir}/CombVCF_AllSites/PHNatAcc_TRANS_${chr}_Comb.vcf"

    echo "/usr/lib/jvm/java-8-openjdk-amd64/bin/java -jar -Xmx86G -Djava.io.tmpdir=$TMP /home/taslima/Tools/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T GenotypeGVCFs \
 $IN -R $refDir/$ref -o $OFIL1 -nt 25  -allSites -stand_call_conf 30 -L $chr:1-$length " >>genogvcf.param

done <$CHRLN


#Core=`wc -l genogvcf.param  |cut -f1 -d ' '`
#if (( $Core % 1 == 0)); then Node="$(($Core/1))";
#        else  Node="$((($Core/1)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J gvcf -N $Node -n $Core -p normal -t 48:00:00 --ntasks-per-node=1 slurm.sh genogvcf.param
#sbatch -J gvcf -N $Node -n $Core -p long -t 120:00:00 --ntasks-per-node=1 slurm.sh genogvcf.param


