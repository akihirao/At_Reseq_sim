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


#=====================================================================
#VariantFiltration for SNP

gatk VariantFiltration\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.raw.snp.vcf.gz\
 --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0"\
 --filter-name "basic_snp_filter"\
 -O AT.simu.snp.filter.vcf

grep -E '^#|PASS' AT.simu.snp.filter.vcf > AT.simu.snp.filterPASSED.vcf

#VariantFiltration for INDEL
gatk VariantFiltration\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.raw.indel.vcf.gz\
 --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0"\
 --filter-name "basic_indel_filter"\
 -O AT.simu.indel.filter.vcf

grep -E '^#|PASS' AT.simu.indel.filter.vcf > AT.simu.indel.filterPASSED.vcf
#=====================================================================


#=====================================================================
#DepthFiltering for SNP: DP < 10 & DP > 200 & GQ <20 (Low Genotype Quality: less than 99%)
gatk VariantFiltration\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.snp.filterPASSED.vcf\
 -G-filter "GQ < 20"\
 -G-filter-name "lowGQ"\
 -G-filter "DP < 10 || DP > 200"\
 -G-filter-name "DP_10-200"\
 -O AT.simu.snp.DPfilterPASSED.vcf

#DepthFiltering for INDEL: DP < 10 & DP > 200 & GQ < 20 (Low Genotype Quality: less than 99%) 
gatk VariantFiltration\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.indel.filterPASSED.vcf\
 -G-filter "GQ < 20"\
 -G-filter-name "lowGQ"\
 -G-filter "DP < 10 || DP > 200"\
 -G-filter-name "DP_10-200" \
 -O AT.simu.indel.DPfilterPASSED.vcf

#Set filtered sites to no call:SNP
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.snp.DPfilterPASSED.vcf\
 --set-filtered-gt-to-nocall\
 -O AT.simu.snp.DPfilterNoCall.vcf
bgzip -c AT.simu.snp.DPfilterNoCall.vcf > AT.simu.snp.DPfilterNoCall.vcf.gz
tabix -f -p vcf AT.simu.snp.DPfilterNoCall.vcf.gz
bcftools index -f AT.simu.snp.DPfilterNoCall.vcf.gz

perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < AT.simu.snp.DPfilterNoCall.vcf > AT.simu.snp.DPfilterNoCall.bed


#Set filtered sites to no call:INDEL
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.indel.DPfilterPASSED.vcf\
 --set-filtered-gt-to-nocall \
 -O AT.simu.indel.DPfilterNoCall.vcf
bgzip -c AT.simu.indel.DPfilterNoCall.vcf > AT.simu.indel.DPfilterNoCall.vcf.gz
tabix -f -p vcf AT.simu.indel.DPfilterNoCall.vcf.gz
bcftools index -f AT.simu.indel.DPfilterNoCall.vcf.gz

perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < AT.simu.indel.DPfilterNoCall.vcf > AT.simu.idel.DPfilterNoCall.bed


gatk MergeVcfs\
 -I AT.simu.snp.DPfilterNoCall.vcf.gz\
 -I AT.simu.indel.DPfilterNoCall.vcf.gz\
 -O AT.simu.snp.indel.DPfilterNoCall.vcf 
bgzip -c AT.simu.snp.indel.DPfilterNoCall.vcf > AT.simu.snp.indel.DPfilterNoCall.vcf.gz
tabix -f -p vcf AT.simu.snp.indel.DPfilterNoCall.vcf.gz
bcftools index -f AT.simu.snp.indel.DPfilterNoCall.vcf.gz


cd $SCRIPT_DIR

module unload samtools/1.10
module unload gatk/4.1.7.0
