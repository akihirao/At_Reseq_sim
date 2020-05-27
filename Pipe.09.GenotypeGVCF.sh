#!/bin/bash -i
#Pipe.09.GenotypeGVCF.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

reference_folder=/zfs/Arabidopsis/Reference_v1.1
main_folder=/zfs/Arabidopsis/work/mutation_sim


module load samtools/1.10
module load gatk/4.1.7.0


input_samples=""
option_lab="-V "
TAIR10_gvcf_lab=".TAIR10.g.vcf.gz"
one_space=" "
slash_lab="/"



output_folder=$main_folder/vcf_out
mkdir -p $output_folder


#Genotype from GVCF
for i in `seq 1 3`; do

	target_ID="AT_simu"
	genomicsDB_folder=genomicsDB.$target_ID.$i
	DB_folder=$main_folder/$genomicsDB_folder

	gatk GenotypeGVCFs \
	-R $reference_folder/TAIR10.fa \
	-V gendb://$DB_folder \
	-O $output_folder/AT.simu.$i.raw.vcf.gz

done


cd $SCRIPT_DIR


module unload samtools/1.10
module unload gatk/4.1.7.0


