#!/bin/bash -i
#Make.Col6909.genome.sh
#making genome fasta of Columbia ecotype (Col) deposited in 1001 genome project
#by HIRAO Akira		

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

intersection="Col_6909"

reference_folder=/zfs/Arabidopsis/Reference_v1.1
reference_nDNA=TAIR10_nDNA
reference_mt=TAIR10_mt
reference_cp=TAIR10_cp

cd $reference_folder

perl /usr/local/simuG/simuG.pl \
-refseq $reference_folder/$reference_nDNA.fa \
-snp_vcf $reference_folder/intersection_6909_chr_edited.snp.vcf \
-indel_vcf $reference_folder/intersection_6909_chr_edited.indel.vcf \
-prefix $intersection


bgzip -f -c $intersection.refseq2simseq.SNP.vcf > $intersection.refseq2simseq.SNP.vcf.gz
tabix -f -p vcf $intersection.refseq2simseq.SNP.vcf.gz
bgzip -f -c $intersection.refseq2simseq.INDEL.vcf > $intersection.refseq2simseq.INDEL.vcf.gz
tabix -f -p vcf $intersection.refseq2simseq.INDEL.vcf.gz

bgzip -f -c intersection_6909_chr_edited.vcf > intersection_6909_chr_edited.vcf.gz
tabix -f -p vcf intersection_6909_chr_edited.vcf.gz



cd $SCRIPT_DIR