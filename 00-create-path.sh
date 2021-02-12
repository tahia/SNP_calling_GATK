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

############################ Step 00: Create Path #####################################################
#I expect the output directory is the top directory that already exists & which already have 
#a directory "raw" where all the raw sequense files will be. Othe directories will be
#created here. So remove anything from there except that "raw" folder.Make sure that the files are decompressed.
#The Structure is like this
# outDir -
# 	-- raw
#       -- Renamed
#       -- QualFiltered
#       -- Mapped
#       -- MapFiltered
#       -- AllGATK
#       -- FinalVCF 
#Or use the following if you want to remove by this script
LC_ALL=C
#rm -r "${outDir}/"[A-Z]*
mkdir "${outDir}/Renamed" "${outDir}/QualFiltered" "${outDir}/Mapped" "${outDir}/MapFiltered" "${outDir}/AllGATK" "${outDir}/FinalVCF" \
 "${outDir}/AddGrpSort" "${outDir}/MarkDup" 

