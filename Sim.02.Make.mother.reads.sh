#!/bin/bash -i
#Sim.02.Make.mother.reads.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

total_coverage=50
half_coverage=$((total_coverage/2))

mt_coverage=200
cp_coverage=6000

total_no_snp=0
total_no_indel=0

mt_no_snp=0
mt_no_indel=0

cp_no_snp=0
cp_no_indel=0


half_no_snp=$((total_no_snp/2))
half_no_indel=$((total_no_indel/2))


fragment_size=450
SD_fragment_size=120


module load vcftools/0.1.15


for i in $(seq 1 3) #roop for serial number 1-3
do

	#no_label=`printf %02d ${i}`
	output_folder_name_head="mother_"
	output_folder_name=$output_folder_name_head$i

	echo $output_folder_name

	reference_folder=/zfs/Arabidopsis/Reference_v1.1
	reference_nDNA=TAIR10_nDNA
	reference_mt=TAIR10_mt
	reference_cp=TAIR10_cp

	output_orig_folder=/zfs/Arabidopsis/work/mutation_sim

	mkdir -p $output_orig_folder/$output_folder_name

	input_folder=/zfs/Arabidopsis/work/mutation_sim/$output_folder_name
	output_folder=$output_orig_folder/$output_folder_name

	cd $output_folder


	#making simulated reads for nDNA haploid 1
	sandy genome -v -t paired-end -j $CPU \
	-M $fragment_size -D $SD_fragment_size \
	-c $half_coverage --quality-profile=hiseq_150 $reference_folder/Col_6909.simseq.genome.fa -p mutant.$i.haploid_1 > sim_1.$i.log

	#making simulated reads for nDNA haploid 2
	sandy genome -v -t paired-end -j $CPU \
	-M $fragment_size -D $SD_fragment_size \
	-c $half_coverage --quality-profile=hiseq_150 $reference_folder/Col_6909.simseq.genome.fa -p mutant.$i.haploid_2 > sim_2.$i.log

	#making simulated reads for mitochondria
	sandy genome -v -t paired-end -j $CPU \
	-M $fragment_size -D $SD_fragment_size \
	-c $mt_coverage --quality-profile=hiseq_150 $reference_folder/$reference_mt.fa -p mutant.$i.mt > mt.$i.log

	#making simulated reads for nDNA chroloplast
	sandy genome -v -t paired-end -j $CPU \
	-M $fragment_size -D $SD_fragment_size \
	-c $cp_coverage --quality-profile=hiseq_150 $reference_folder/$reference_cp.fa -p mutant.$i.cp > cp.$i.log


	cat mutant.$i.haploid_1_R1_001.fastq.gz mutant.$i.haploid_2_R1_001.fastq.gz mutant.$i.mt_R1_001.fastq.gz mutant.$i.cp_R1_001.fastq.gz > $output_folder_name.TAIR10_R1_001.fastq.gz
	cat mutant.$i.haploid_1_R2_001.fastq.gz mutant.$i.haploid_2_R2_001.fastq.gz mutant.$i.mt_R2_001.fastq.gz mutant.$i.cp_R2_001.fastq.gz > $output_folder_name.TAIR10_R2_001.fastq.gz


	cd $SCRIPT_DIR

done

module unload vcftools/0.1.15
