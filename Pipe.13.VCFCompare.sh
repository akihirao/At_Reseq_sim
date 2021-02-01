#!/bin/bash -i
#FamilyTAIR10.8.VCFCompare.sh
#from 2020,1.10
#by HIRAO Akira


set -exuo pipefail

SCRIPT_DIR=$(cd $(dirname $0)  && pwd)

reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0
module load vcftools/0.1.15
module load bedops/2.4.39


output_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
vcf_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
main_folder=/zfs/Arabidopsis/work/mutation_sim/
cd $output_folder


confirm_mutation_summary_file="confirm_mutation_summary."
echo -n >| $confirm_mutation_summary_file.txt

echo "No_source_mu" "No_detected_mu"  "No_detected_family_mu" "No_detected_homo_mu"  "No_detected_hetero_mu" >> $output_folder/$confirm_mutation_summary_file.txt
#-----------------------------------------------------
# defining the argument for 48 samples
samples_12=()

while read sample; do
	echo $sample
	samples_12+=($sample)
done < $SCRIPT_DIR/sample_ID.list #list of samples

echo $samples_12

mother_vec=(${samples_12[@]:0:2})
M2_vec=(${samples_12[@]:3:11})
echo ${mother_vec[@]}
echo ${M2_vec[@]}



for target_sample in ${M2_vec[@]}
do

	cd $target_sample

	gatk LeftAlignAndTrimVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $main_folder/$target_sample/diploid.mutations.list.vcf\
	 -O diploid.mutations.realigned.list.vcf
	bgzip -c diploid.mutations.realigned.list.vcf > diploid.mutations.realigned.list.vcf.gz
	tabix -f -p vcf diploid.mutations.realigned.list.vcf.gz


	##select homozygous mutation sites per samples
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V  $target_sample.all.vcf\
	 -select "vc.getGenotype('${target_sample}').isHomVar()"\
	 --sample-name $target_sample\
	 -O $target_sample.all.homo.vcf
	bgzip -c $target_sample.all.homo.vcf > $target_sample.all.homo.vcf.gz
	tabix -f -p vcf $target_sample.all.homo.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.all.homo.vcf > $target_sample.all.homo.bed

	##select homozygous mutation sites per samples
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V  $target_sample.all.vcf\
	 -select "vc.getGenotype('${target_sample}').isHet()"\
	 --sample-name $target_sample\
	 -O $target_sample.all.hetero.vcf
	bgzip -c $target_sample.all.hetero.vcf > $target_sample.all.hetero.vcf.gz
	tabix -f -p vcf $target_sample.all.hetero.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.all.hetero.vcf > $target_sample.all.hetero.bed


	vcf-compare diploid.mutations.realigned.list.vcf.gz $target_sample.all.vcf.gz > vcf_compare_output.txt

	vcf2bed <  diploid.mutations.realigned.list.vcf > diploid.mutations.realigned.list.bed
	vcf2bed <  $target_sample.all.vcf > $target_sample.all.bed

	no_source_mutation=`wc -l diploid.mutations.realigned.list.bed |awk '{print $1}'`
	no_detected_mutation=`wc -l $target_sample.all.bed |awk '{print $1}'`
	no_detected_family_mutation=`wc -l $target_sample.familyclustered.bed |awk '{print $1}'`
	no_detected_homo_mutation=`wc -l $target_sample.all.homo.bed |awk '{print $1}'`
	no_detected_hetero_mutation=`wc -l $target_sample.all.hetero.bed |awk '{print $1}'`

	confirm_rates=$(($no_detected_mutation/$no_source_mutation))
	echo $no_source_mutation $no_detected_mutation $no_detected_family_mutation $no_detected_homo_mutation $no_detected_hetero_mutation>> $output_folder/$confirm_mutation_summary_file.txt
 
 	cd ../
done



module unload samtools/1.10
module unload gatk/4.1.7.0
module unload vcftools/0.1.15
module unload bedops/2.4.39
