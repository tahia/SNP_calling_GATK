############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work/02786/taslima/dbs/PH #Reference directory where the reference genome file will be
ref=Phallii_308_v2.0.fa # Name of reference genome file
outDir=/scratch/02786/taslima/data/phalli/Phal_RILSeq_v2 # output directory. It must be created before running the script
met=/scratch/02786/taslima/data/phalli/RIL_meta.tab # Full path of meta file
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
rm -r "${outDir}/"[A-Z]*
mkdir "${outDir}/Renamed" "${outDir}/QualFiltered" "${outDir}/Mapped" "${outDir}/MapFiltered" "${outDir}/AllGATK" "${outDir}/FinalVCF" \
 "${outDir}/AddGrpSort" "${outDir}/MarkDup" 

