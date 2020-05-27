#!/bin/bash -i
#Pipe.10.SelectVariants.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0

#define mendelian violation quality threshold
GQ_threshold=20

output_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
cd $output_folder

for i in `seq 1 3`;
do

	#Output mendelian violation site only: --pedigree & --mendelian-violation
	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.raw.vcf.gz \
	--pedigree $SCRIPT_DIR/AT.simu.$i.family.ped \
	--mendelian-violation \
	--mendelian-violation-qual-threshold $GQ_threshold \
	-O AT.simu.$i.mutation_candidates.vcf.gz

	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.mutation_candidates.vcf.gz \
	-select-type SNP \
	-O AT.simu.$i.raw.snp.vcf.gz

	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.mutation_candidates.vcf.gz \
	-select-type INDEL \
	-O AT.simu.$i.raw.indel.vcf.gz

done	

cd $SCRIPT_DIR


module unload samtools/1.10
module unload gatk/4.1.7.0


