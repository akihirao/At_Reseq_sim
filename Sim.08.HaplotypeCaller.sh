#!/bin/bash -i
#Sim.08.HaplotypeCaller.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0



while read sample fastq_R1 fastq_R2; do

	output_folder=/zfs/Arabidopsis/work/mutation_sim/$sample
	cd $output_folder

	gatk HaplotypeCaller\
	 -R $reference_folder/TAIR10.fa\
	 -I $sample.TAIR10.bqsr.bam\
	 --emit-ref-confidence GVCF \
	 --bam-output $sample.TAIR10.hpcall.bam\
	 -O $sample.TAIR10.g.vcf.gz 


done < $SCRIPT_DIR/fastq_list.txt #list of Simulation IDs and their reads

cd $SCRIPT_DIR



module unload samtools/1.10
module unload gatk/4.1.7.0



