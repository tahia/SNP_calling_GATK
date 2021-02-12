# SNP_calling_GATK

This is the step by step pile for running GATK to call high quality SNP and it is designed to run on cluster.

## This script is a part of genome-wide SNP Calling Pipeline for Plants by implementing Genome Analysis Toolkit (GATK)    
## For further information about GATK please visit : https://gatk.broadinstitute.org/hc/en-us                             
## Detail description of this pipe can be found in github: https://github.com/tahia/SNP_calling_GATK                      
## Author : Taslima Haque                                                                                                 
## Last modified: 12th Feb,2021                                                                                           
## Please send your query to the author at: taslima@utexas.edu or tahiadu@gmail.com                                       

What it expects?

refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be

ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file

outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V3 # output directory. It must be created before running the script

met=/work/02786/taslima/stampede2/pipes/SNP_calling_GATK/JGI_DL_78_Design.tab # Full path of meta file

TMP=/scratch/02786/taslima/data/phalli/Temp

CHRFIL=/work/02786/taslima/stampede2/dbs/PH/PhalliiHAL_496_v2.0.chr #Name of Chromosomes one in each line


And in outDir/raw all the fastq files will be there

Here is the sample of Meta file that is tab separated with feilds of sample name, library name and barcode

FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
FH.2.06 1       AGBTB   8829.1.113057.GATCAG
FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
FH.7.06 1       YPGT    8577.7.104714.ACGATA

Step 00: Create Path

I expect the output directory is the top directory that already exists & which already have a directory "raw" where all the raw sequense files will be. Othe directories will be created here. So remove anything from there except that "RAW_DATA" folder.Make sure that the files are decompressed. The Structure is like this:

 outDir -
 	     -- RAW_DATA
       -- Renamed
       -- QualFiltered
       -- Mapped
       -- MapFiltered
       -- AllGATK
       -- FinalVCF 


Step 1: Decopress and Rename 

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

Step 9: Split BAM by Chromosome

Step 10: RUN BAM INDEX : ROUND 3

Step 11: GATK RealignerTargetCreator

First step for GATK. It will list the target intervals for variants

Step 12: GATK IndelRealigner

Will realign in the region of Indel and how we want the SNP variants there.

Step 13: PICARD RESORT

Step 14: RUN BAM INDEX : Round 4

Step 15: RUN GATK to call raw CALL SNP

You can use either HaplotypeCaller (HC) or UnifiedGenotyper (UG). UG has more miscall for heterozygous alleles so I personally prefer HC. 

Step 16: MERGE VCF

This step is needed if SNP calling has done across Chromsomes parallelly or using specific Intervals


