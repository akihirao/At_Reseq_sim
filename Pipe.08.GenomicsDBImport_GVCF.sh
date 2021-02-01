#!/bin/bash -i
#Pipe.08.GenomicsDBImport_GVCF.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=12

reference_folder=/zfs/Arabidopsis/Reference_v1.1

main_folder=/zfs/Arabidopsis/work/mutation_sim


module load samtools/1.10
module load gatk/4.1.7.0



#input for genomic db import

input_samples=""
option_lab="-V "
TAIR10_gvcf_lab=".TAIR10.g.vcf.gz"
one_space=" "
slash_lab="/"


while read sample; do

	echo $sample
	gvcf_folder=$main_folder/$sample$slash_lab
		
	input_samples=$input_samples$option_lab$gvcf_folder$sample$TAIR10_gvcf_lab$one_space

done < $SCRIPT_DIR/family.list.txt #list of IDs in the same family


target_ID="AT_simu"
genomicsDB_folder=genomicsDB.$target_ID
DB_folder=$main_folder/$genomicsDB_folder

#Prepare priori header list of reference fasta (Chr1-5.list)!!
gatk GenomicsDBImport\
 $input_samples\
 --genomicsdb-workspace-path  $DB_folder\
 --intervals $SCRIPT_DIR/AT_Chr1-5.list\
 --reader-threads $CPU

cd $SCRIPT_DIR


module unload samtools/1.10
module unload gatk/4.1.7.0


