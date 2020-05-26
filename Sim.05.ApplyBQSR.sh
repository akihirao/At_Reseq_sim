#!/bin/bash -i
#Sim.05.ApplyBQSR.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

reference_folder=/zfs/Arabidopsis/Reference_v1.1
dbSNP_folder=/zfs/Arabidopsis/dbSNP/1001Genomes_6909

module load samtools/1.10
module load gatk/4.1.7.0



while read sample fastq_R1 fastq_R2; do

	output_folder=/zfs/Arabidopsis/work/mutation_sim/$sample
	cd $output_folder
	
	gatk ApplyBQSR \
	-I $sample.TAIR10.filtered.bam \
	-bqsr $sample.TAIR10.recal_data.table \
	-O $sample.TAIR10.bqsr.bam

done < $SCRIPT_DIR/fastq_list.txt #list of Simulation IDs and their reads

cd $SCRIPT_DIR


module unload samtools/1.10
module unload gatk/4.1.7.0

