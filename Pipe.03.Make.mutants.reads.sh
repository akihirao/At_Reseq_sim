#!/bin/bash -i
#Pipe.03.Make.mutants.reads.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

echo $SCRIPT_DIR


CPU=16

total_coverage=50
half_coverage=$((total_coverage/2))

mt_coverage=200
cp_coverage=6000

total_no_snp=2000
total_no_indel=1000

mt_no_snp=10
mt_no_indel=5

cp_no_snp=4
cp_no_indel=2

half_no_snp=$((total_no_snp/2))
half_no_indel=$((total_no_indel/2))


fragment_size=450
SD_fragment_size=120


module load vcftools/0.1.15


for i in $(seq 1 3); do #roop for serial number 1-3
	for j in $(seq 1 3); do #roop for serial number 1-3

		underbar_lab="_"
		output_folder_name_head="simu_"
		output_folder_name=$output_folder_name_head$i$underbar_lab$j

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


		#Making mutant reference for nDNA diploid
		perl /usr/local/simuG/simuG.pl \
		-refseq $reference_folder/$reference_nDNA.fa \
		-snp_count $total_no_snp \
		-indel_count $total_no_indel \
		-prefix diploid

		bgzip -f -c diploid.refseq2simseq.SNP.vcf > diploid.refseq2simseq.SNP.vcf.gz
		tabix -f -p vcf diploid.refseq2simseq.SNP.vcf.gz
		bgzip -f -c diploid.refseq2simseq.INDEL.vcf > diploid.refseq2simseq.INDEL.vcf.gz
		tabix -f -p vcf diploid.refseq2simseq.INDEL.vcf.gz

		#concatenating mutation SNPs + INDELs + Col 6090 variants
		vcf-concat diploid.refseq2simseq.SNP.vcf.gz diploid.refseq2simseq.INDEL.vcf.gz  | gzip -c > diploid.SNP_INDEL.unsorted.vcf.gz
		vcf-sort diploid.SNP_INDEL.unsorted.vcf.gz > diploid.SNP_INDEL.vcf

		#変異を  haploid別の vcfファイルに分割する  自作perlスクリプト
		perl $SCRIPT_DIR/VCF_dividing.pl diploid.SNP_INDEL.vcf

		#vcf2model.plを用いてユーザー指定VCFの変異入りゲノムを発生させる
		perl /usr/local/simuG/vcf2model.pl -vcf haploid1.mutant.SNP_INDEL.vcf -prefix haploid1
		perl /usr/local/simuG/vcf2model.pl -vcf haploid2.mutant.SNP_INDEL.vcf -prefix haploid2

		bgzip -f -c haploid1.mutant.SNP_INDEL.vcf > haploid1.mutant.SNP_INDEL.vcf.gz
		tabix -f -p vcf haploid1.mutant.SNP_INDEL.vcf.gz
		bgzip -f -c haploid2.mutant.SNP_INDEL.vcf > haploid2.mutant.SNP_INDEL.vcf.gz
		tabix -f -p vcf haploid2.mutant.SNP_INDEL.vcf.gz

		# Columbia 6906のSNP＆INDELを反映させる
		vcf-concat haploid1.mutant.SNP_INDEL.vcf.gz  $reference_folder/Col_6909.refseq2simseq.SNP.vcf.gz  $reference_folder/Col_6909.refseq2simseq.INDEL.vcf.gz | gzip -c > haploid1.mutant.Col.SNP_INDEL.unsorted.vcf.gz
		vcf-sort haploid1.mutant.Col.SNP_INDEL.unsorted.vcf.gz > haploid1.mutant.Col.SNP_INDEL.vcf
		vcf-concat haploid2.mutant.SNP_INDEL.vcf.gz  $reference_folder/Col_6909.refseq2simseq.SNP.vcf.gz  $reference_folder/Col_6909.refseq2simseq.INDEL.vcf.gz | gzip -c > haploid2.mutant.Col.SNP_INDEL.unsorted.vcf.gz
		vcf-sort haploid2.mutant.Col.SNP_INDEL.unsorted.vcf.gz > haploid2.mutant.Col.SNP_INDEL.vcf

		bgzip -f -c haploid1.mutant.Col.SNP_INDEL.vcf > haploid1.mutant.Col.SNP_INDEL.vcf.gz
		tabix -f -p vcf haploid1.mutant.Col.SNP_INDEL.vcf.gz
		bgzip -f -c haploid2.mutant.Col.SNP_INDEL.vcf > haploid2.mutant.Col.SNP_INDEL.vcf.gz
		tabix -f -p vcf haploid2.mutant.Col.SNP_INDEL.vcf.gz

		cat $reference_folder/$reference_nDNA.fa | vcf-consensus haploid1.mutant.Col.SNP_INDEL.vcf.gz > haploid1.mutant.genome.fa
		cat $reference_folder/$reference_nDNA.fa | vcf-consensus haploid2.mutant.Col.SNP_INDEL.vcf.gz > haploid2.mutant.genome.fa


		#Making mutant reference for mitochondria
		perl /usr/local/simuG/simuG.pl \
		-refseq $reference_folder/$reference_mt.fa \
		-snp_count $mt_no_snp \
		-indel_count $mt_no_indel \
		-prefix mt

		#Making mutant reference for chroloplast
		perl /usr/local/simuG/simuG.pl \
		-refseq $reference_folder/$reference_cp.fa \
		-snp_count $cp_no_snp \
		-indel_count $cp_no_indel \
		-prefix cp


		#making simulated reads for nDNA haploid 1
		sandy genome -v -t paired-end -j $CPU \
		-M $fragment_size -D $SD_fragment_size \
		-c $half_coverage --quality-profile=hiseq_150 haploid1.mutant.genome.fa -p mutant.haploid_1 > sim_1.log

		#making simulated reads for nDNA haploid 2
		sandy genome -v -t paired-end -j $CPU \
		-M $fragment_size -D $SD_fragment_size \
		-c $half_coverage --quality-profile=hiseq_150 haploid2.mutant.genome.fa -p mutant.haploid_2 > sim_2.log

		#making simulated reads for mitochondria
		sandy genome -v -t paired-end -j $CPU \
		-M $fragment_size -D $SD_fragment_size \
		-c $mt_coverage --quality-profile=hiseq_150 mt.simseq.genome.fa -p mutant.mt > mt.log

		#making simulated reads for nDNA chroloplast
		sandy genome -v -t paired-end -j $CPU \
		-M $fragment_size -D $SD_fragment_size \
		-c $cp_coverage --quality-profile=hiseq_150 cp.simseq.genome.fa -p mutant.cp > cp.log


		cat mutant.haploid_1_R1_001.fastq.gz mutant.haploid_2_R1_001.fastq.gz mutant.mt_R1_001.fastq.gz mutant.cp_R1_001.fastq.gz > $output_folder_name.TAIR10_R1_001.fastq.gz
		cat mutant.haploid_1_R2_001.fastq.gz mutant.haploid_2_R2_001.fastq.gz mutant.mt_R2_001.fastq.gz mutant.cp_R2_001.fastq.gz > $output_folder_name.TAIR10_R2_001.fastq.gz


		cd $SCRIPT_DIR

	done

done

module unload vcftools/0.1.15
