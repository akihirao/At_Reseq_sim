#!/bin/bash -i
#Pipe.11.VariantFiltration.sh
#by HIRAO Akira

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

CPU=16

reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0


output_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
cd $output_folder


for i in `seq 1 3`; do

	#=====================================================================
	#VariantFiltration for SNP

	gatk VariantFiltration \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.raw.snp.vcf.gz \
	--filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0" \
	--filter-name "basic_snp_filter" \
	-O AT.simu.$i.snp.filter.vcf

	grep -E '^#|PASS' AT.simu.$i.snp.filter.vcf > AT.simu.$i.snp.filterPASSED.vcf

	#VariantFiltration for INDEL
	gatk VariantFiltration \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.raw.indel.vcf.gz \
	--filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0" \
	--filter-name "basic_indel_filter" \
	-O AT.simu.$i.indel.filter.vcf

	grep -E '^#|PASS' AT.simu.$i.indel.filter.vcf > AT.simu.$i.indel.filterPASSED.vcf
	#=====================================================================


	#=====================================================================
	#DepthFiltering for SNP: DP < 10 & DP > 200 & GQ <20 (Low Genotype Quality: less than 99%)
	gatk VariantFiltration \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.snp.filterPASSED.vcf \
	-G-filter "GQ < 20" \
	-G-filter-name "lowGQ" \
	-G-filter "DP < 10 || DP > 200" \
	-G-filter-name "DP_10-200" \
	-O AT.simu.$i.snp.DPfilterPASSED.vcf

	#DepthFiltering for INDEL: DP < 10 & DP > 200 & GQ < 20 (Low Genotype Quality: less than 99%) 
	gatk VariantFiltration \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.indel.filterPASSED.vcf \
	-G-filter "GQ < 20" \
	-G-filter-name "lowGQ" \
	-G-filter "DP < 10 || DP > 200" \
	-G-filter-name "DP_10-200" \
	-O AT.simu.$i.indel.DPfilterPASSED.vcf

	#Set filtered sites to no call:SNP
	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.snp.DPfilterPASSED.vcf \
	--set-filtered-gt-to-nocall \
	-O AT.simu.$i.snp.DPfilterNoCall.vcf
	bgzip -c AT.simu.$i.snp.DPfilterNoCall.vcf > AT.simu.$i.snp.DPfilterNoCall.vcf.gz
	tabix -f -p vcf AT.simu.$i.snp.DPfilterNoCall.vcf.gz
	bcftools index -f AT.simu.$i.snp.DPfilterNoCall.vcf.gz

	#Set filtered sites to no call:INDEL
	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.indel.DPfilterPASSED.vcf \
	--set-filtered-gt-to-nocall \
	-O AT.simu.$i.indel.DPfilterNoCall.vcf
	bgzip -c AT.simu.$i.indel.DPfilterNoCall.vcf > AT.simu.$i.indel.DPfilterNoCall.vcf.gz
	tabix -f -p vcf AT.simu.$i.indel.DPfilterNoCall.vcf.gz
	bcftools index -f AT.simu.$i.indel.DPfilterNoCall.vcf.gz

done

cd $SCRIPT_DIR

module unload samtools/1.10
module unload gatk/4.1.7.0

