#!/bin/bash -i
#Pipe.01.Mather.genome.sh
#by HIRAO Akira		

set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

intersection="Col_6909"

reference_folder=/zfs/Arabidopsis/Reference_v1.1
reference_nDNA=TAIR10_nDNA
reference_mt=TAIR10_mt
reference_cp=TAIR10_cp
mother_vcf_folder=/zfs/Arabidopsis/work/At_Reseq/others/control_mothers

cd $reference_folder

#二倍体生物として2セット分の参照配列を用意しておくことが課題！
perl /usr/local/simuG/simuG.pl\
 -refseq $reference_folder/$reference_nDNA.fa\
 -snp_vcf $mother_vcf_folder/AT01.snp.filtered.vcf\
 -indel_vcf $mother_vcf_folder/AT01.indel.filtered.vcf\
 -prefix AT.1

perl /usr/local/simuG/simuG.pl\
 -refseq $reference_folder/$reference_nDNA.fa\
 -snp_vcf $mother_vcf_folder/AT02.snp.filtered.vcf\
 -indel_vcf $mother_vcf_folder/AT02.indel.filtered.vcf\
 -prefix AT.2

perl /usr/local/simuG/simuG.pl\
 -refseq $reference_folder/$reference_nDNA.fa\
 -snp_vcf $mother_vcf_folder/AT03.snp.filtered.vcf\
 -indel_vcf $mother_vcf_folder/AT03.indel.filtered.vcf\
 -prefix AT.3


#以下は 突然変異の同定用に事前に用意しておくことが課題
#bgzip -f -c $intersection.refseq2simseq.SNP.vcf > $intersection.refseq2simseq.SNP.vcf.gz
#tabix -f -p vcf $intersection.refseq2simseq.SNP.vcf.gz
#bgzip -f -c $intersection.refseq2simseq.INDEL.vcf > $intersection.refseq2simseq.INDEL.vcf.gz
#tabix -f -p vcf $intersection.refseq2simseq.INDEL.vcf.gz

#bgzip -f -c intersection_6909_chr_edited.vcf > intersection_6909_chr_edited.vcf.gz
#tabix -f -p vcf intersection_6909_chr_edited.vcf.gz


cd $SCRIPT_DIR
