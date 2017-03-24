# SNP_calling_GATK

This is the step by step pile for running GATK to call high quality SNP and it is designed to run on cluster.

What it expects?

refDir=/work/mypath/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=Phallii_308_v2.0.fa # Name of reference genome file
outDir=/scratch/mypath/taslima/data/phalli/Phal_RILSeq_v2 # output directory. It must be created before running the script
met=/scratch/mypath/taslima/data/phalli/RIL_meta.tab # Full path of meta file
TMP=/scratch/mypath/taslima/data/phalli/Temp

And in outDir/raw all the fastq files will be there

Step 00: Create Path

I expect the output directory is the top directory that already exists & which already have a directory "raw" where all the raw sequense files will be. Othe directories will be created here. So remove anything from there except that "raw" folder.Make sure that the files are decompressed. The Structure is like this:

 outDir -
 	     -- raw
       -- Renamed
       -- QualFiltered
       -- Mapped
       -- MapFiltered
       -- AllGATK
       -- FinalVCF 


Step 1: Rename 

Depending on the naming pattern please change code of this step so that you have name of your sample , library and barcode.

Step 2: RUN QUAL FILTER

Step 3: RUN MAP
If you have all index files (bwa index for mapping and samtool faidx and picard dictionary) of your reference genome ignore Step 3-01: RUN MAP Index and run Step 3-2: RUN MAP

We have used bwa mem to map reads with default param using four thread for each sample file.

Step 4: RUN MAP FILTER

Filter unmapped and poorly mapped read with -q 20 using samtools

Step 5: RUN PICARD ADD READ GRP & SORT COORD

Add sample ID and barcode in map file

Step 6: RUN BAM INDEX : Round 1

Step 7: RUN MARK DUP 

Mark duplicated read so taht it will not count more than once

Step 8: RUN BAM INDEX : ROUND 2

Step 9: GATK RealignerTargetCreator

First step for GATK. It will list the target intervals for variants

Step 10: GATK IndelRealigner

Will realign in the region of Indel and how we want the SNP variants there.

Step 11: PICARD RESORT

Step 12: RUN BAM INDEX : Round 3

Step 13: RUN GATK to call raw CALL SNP

You can use either HaplotypeCaller (HC) or UnifiedGenotyper (UG). UG has more miscall for heterozygous alleles so I personally prefer HC. Follow through step 14 with corresponding scripts for either HC or UG.

Step 14-01: Filter gVCF

This step is only for HC. Please look into the perl script "gVCF_parser.pl" before using it. You will only use that if you need a filter of this kind

Step 14 or 14-02: MERGE VCF or gVCF

It will merge all the samples into one single VCF and after this point you will have only one VCF file.

Step 15: FILTER VCF

Step 16: Grep SNP


