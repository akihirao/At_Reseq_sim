#!/bin/bash -i
#Pipe.10.SelectVariants.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=12

reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0

#define mendelian violation quality threshold
GQ_threshold=20

output_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
cd $output_folder


gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.raw.vcf.gz\
 -select-type SNP\
 -O AT.simu.raw.snp.vcf.gz

gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.raw.vcf.gz\
 -select-type INDEL\
 -O AT.simu.raw.indel.vcf.gz
	

cd $SCRIPT_DIR


module unload samtools/1.10
module unload gatk/4.1.7.0


