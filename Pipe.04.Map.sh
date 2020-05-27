#!/bin/bash -i
#Pipe.04.Map.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16


#folder stored in reference fasta (TAIR10)
reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load bwa


while read sample fastq_R1 fastq_R2; do

	output_folder=/zfs/Arabidopsis/work/mutation_sim/$sample
	cd $output_folder
		
	#setting RG: @RG\tID:simuG\tSM:$sample\tPL:Illumina
	tag_read_group_part1="@RG\tID:"
	tag_read_group_part2="\tSM:"
	tag_read_group_part3="\tPL:Illumina"
	specific_ID="simuG"
	tag_read_group=$tag_read_group_part1$specific_ID$tag_read_group_part2$sample$tag_read_group_part3

	bwa mem -t $CPU -M -R $tag_read_group $reference_folder/TAIR10.fa $fastq_R1 $fastq_R2 | samtools view -@ $CPU -b | samtools sort -@ $CPU > $sample.TAIR10.bam
	samtools index -@ $CPU $sample.TAIR10.bam
	
done < $SCRIPT_DIR/fastq_list.txt #list of Simulation IDs and their reads

cd $SCRIPT_DIR


module unload samtools/1.10
module unload bwa
