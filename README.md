# SNP_calling_GATK

#### This is the step by step pile for running GATK to call high quality SNP and it is designed to run on cluster.

#### This script is a part of genome-wide SNP Calling Pipeline for Plants by implementing Genome Analysis Toolkit (GATK)    
#### For further information about GATK please visit : https://gatk.broadinstitute.org/hc/en-us                             
#### Detail description of this pipe can be found in github: https://github.com/tahia/SNP_calling_GATK                      
#### Author : Taslima Haque                                                                                                 
#### Last modified: 30th June,2022                                                                                           
#### Please send your query to the author at: taslima@utexas.edu or tahiadu@gmail.com                                       




#### What it expects?

Here is the example header of each script which expect followng variables:

```

refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be

ref=PhalliiHAL_496_v2.0.softmasked.fa # Name of reference genome file

outDir=/scratch/02786/taslima/data/PHNATAcc/Analysis/V7 # output directory. It must be created before running the script

met=/scratch/02786/taslima/data/phalli/RIL_meta.tab # Full path of meta file

TMP=/scratch/02786/taslima/data/phalli/Temp
```


And in outDir/RAW_DATA all the fastq files will be there

Here is the sample of Meta file that is tab separated with feilds of sample name, library name and barcode

- FH.1.06 1       AGBTU   8829.1.113057.GGCTAC
- FH.2.06 1       AGBTB   8829.1.113057.GATCAG
- FH.4.06 1       BHOSB   10980.5.187926.GAGCTCA-TTGAGCT
- FH.5.06 1       BHOSC   10980.5.187926.ATAGCGG-ACCGCTA
- FH.7.06 1       YPGT    8577.7.104714.ACGATA

### Tools requried:
      -- fastx_toolkit
      -- bwa
      -- picard
      -- samtools
      -- gatk/3.8.0

#### Step 00: Create Path

I expect the output directory is the top directory that already exists & which already have a directory "RAW_DATA" where all the raw sequense files will be. Othe directories will be created here. So remove anything from there except that "RAW_DATA" folder.Make sure that the files are decompressed. The Structure is like this:

 ### outDir:
 	        RAW_DATA
            Renamed
            QualFiltered
            Mapped
            MapFiltered
            AllGATK
            FinalVCF


#### Step 1: Decopress and Rename

 Depending on the naming pattern please change code of this step so that you have name of your sample , library and barcode.

#### Step 2: RUN QUAL FILTER

#### Step 3: RUN MAP

 If you have all index files (bwa index for mapping and samtool faidx and picard dictionary) of your reference genome ignore Step 3-01: RUN MAP Index and run Step   3-2: RUN MAP

 We have used bwa mem to map reads with default param using four thread for each sample file.

#### Step 4: RUN MAP FILTER

 Filter unmapped and poorly mapped read with -q 20 using samtools

#### Step 5: RUN PICARD ADD READ GRP & SORT COORD

 Add sample ID and barcode in map file

#### Step 6: RUN BAM INDEX : Round 1

#### Step 7: RUN MARK DUP

 Mark duplicated read so taht it will not count more than once

#### Step 8: RUN BAM INDEX : ROUND 2

#### Step 9: GATK RealignerTargetCreator

 First step for GATK. It will list the target intervals for variants

#### Step 10: GATK IndelRealigner

 Will realign in the region of Indel and how we want the SNP variants there.

#### Step 11: PICARD RESORT

#### Step 12: RUN BAM INDEX : Round 4

#### Step 13: RUN GATK to call raw CALL SNP

 You can use either HaplotypeCaller (HC) or UnifiedGenotyper (UG). UG has more miscall for heterozygous alleles so I personally prefer HC.

#### Step 14: RUN BAM INDEX & FILTER SNP, INDEL : ROUND 3

#### Step 15: Base Quality Recalibration

#### Step 16 & 17 : Repeat variant calling

#### Step 18 & 19 : Filter variants : Round 2

#### Step 20 : Filter non-variant sites
