#!/bin/bash -i
#Pipe.12.IdintifyingMutation.sh
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

BioAlcidaeJdk_path=/usr/local/jvarkit/dist

mutation_summary_file_all="mutation_summary.gatk.all"
mutation_summary_file_hetero="mutation_summary.gatk.hetero"
mutation_summary_file_homo="mutation_summary.gatk.homo"
mutation_summary_file_familyclustered="mutation_summary.gatk.familyclustered"
mutation_list_file="M2.mutation_list.gatk"


cd $output_folder


echo -n >| M2.snp.unsorted.all.bed
echo -n >| M2.indel.unsorted.all.bed

echo -n >| $mutation_summary_file_all.txt
echo -n >| $mutation_summary_file_hetero.txt
echo -n >| $mutation_summary_file_homo.txt
echo -n >| $mutation_summary_file_familyclustered.txt

echo -n >| $mutation_list_file.all.unsort.txt
echo -n >| $mutation_list_file.hetero.unsort.txt
echo -n >| $mutation_list_file.homo.unsort.txt
echo -n >| $mutation_list_file.familyclustered.unsort.txt



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


#----------------------------------------------------------------------------------
#Output mendelian violation site only: --pedigree & --mendelian-violation
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.snp.indel.DPfilterNoCall.vcf.gz\
 --pedigree $SCRIPT_DIR/AT.simu.family.ped\
 --mendelian-violation\
 --mendelian-violation-qual-threshold 30\
 --exclude-filtered\
 -O AT.simu.mu.snp.indel.DPfilterNoCall.vcf.gz
bcftools index -f AT.simu.mu.snp.indel.DPfilterNoCall.vcf.gz
bcftools view AT.simu.mu.snp.indel.DPfilterNoCall.vcf.gz\
 -Ov -o AT.simu.mu.snp.indel.DPfilterNoCall.vcf

#select variants with max-nocall-fraction 0.0
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.mu.snp.indel.DPfilterNoCall.vcf\
 --max-nocall-fraction 0.0\
 --exclude-filtered\
 -O AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz

gunzip -c AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz > AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf

#---------------------------------------------------------------------------------------------------------------
#select family-clustered variants
perl $SCRIPT_DIR/FamilyClusterMyu.extract.pl < AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf > AT.simu.family.clustered.mu.vcf

bgzip -c AT.simu.family.clustered.mu.vcf > AT.simu.family.clustered.mu.vcf.gz
tabix -f -p vcf AT.simu.family.clustered.mu.vcf.gz

#select variants with max-nocall-fraction 0.0
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.family.clustered.mu.vcf.gz\
 --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
 --max-nocall-fraction 0\
 --exclude-filtered\
 -O AT.M2.family.clustered.mu.vcf.gz

gunzip -c AT.M2.family.clustered.mu.vcf.gz > AT.M2.family.clustered.mu.vcf

#---------------------------------------------------------------------------------------------------------------




#identifying unique SNVs with using bioalcidaejdk.jar
#See detail for https://www.biostars.org/p/329423/#329742
java -jar $BioAlcidaeJdk_path/bioalcidaejdk.jar -e 'stream().forEach(V->{final List<Genotype> L=V.getGenotypes().stream().filter(G->G.isHet() || G.isHomVar()).collect(Collectors.toList());if(L.size()!=1) return;final Genotype g=L.get(0);println(V.getContig()+" "+V.getStart()+" "+V.getReference()+" "+g.getSampleName()+" "+g.getAlleles());});' AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf > AT.simu.unique.snp.indel.list.txt

perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < AT.simu.unique.snp.indel.list.txt > AT.simu.unique.bed


#select back variants with unique.bed 
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
 -L AT.simu.unique.bed\
 --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
 -O AT.simu.M2.unique.unfiltered.neighbor.vcf


##filtering out combined mutations
perl $SCRIPT_DIR/FilteringVcfNeighborSNVs.pl < AT.simu.M2.unique.unfiltered.neighbor.vcf > AT.simu.M2.unique.unfiltered.non_neighbor.vcf
bgzip -c AT.simu.M2.unique.unfiltered.non_neighbor.vcf > AT.simu.M2.unique.unfiltered.non_neighbor.vcf.gz
tabix -f -p vcf AT.simu.M2.unique.unfiltered.non_neighbor.vcf.gz

#filtering out non genotyped sites 
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.M2.unique.unfiltered.non_neighbor.vcf.gz\
 --max-nocall-fraction 0\
 --exclude-filtered\
 -O AT.simu.M2.unique.non_neighbor.vcf.gz


##<< COMMENTOUT

for target_sample in ${M2_vec[@]}
do

	mkdir -p $target_sample
	cd $target_sample

	##select mutation sites per samples	
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $vcf_folder/AT.simu.M2.unique.non_neighbor.vcf.gz\
	 --sample-name $target_sample\
	 -O $target_sample.unique.non_neighbor.vcf
	##

	#selecting heterozygous mutations; AF < 25% && AF > 80% && GQ < 99
	perl $SCRIPT_DIR/VariantFilteredAF_hetero.pl < $target_sample.unique.non_neighbor.vcf > $target_sample.hetero.vcf
	bgzip -c $target_sample.hetero.vcf > $target_sample.hetero.vcf.gz
	tabix -f -p vcf $target_sample.hetero.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.hetero.vcf > $target_sample.hetero.bed
	##

	#selecting homozygous mutations;  AF >= 80%
	perl $SCRIPT_DIR/VariantFilteredAF_homo.pl < $target_sample.unique.non_neighbor.vcf > $target_sample.homo.vcf
	bgzip -c $target_sample.homo.vcf > $target_sample.homo.vcf.gz
	tabix -f -p vcf $target_sample.homo.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.homo.vcf > $target_sample.homo.bed
	##

	##select intra-family shared mutation sites per samples
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $vcf_folder/AT.M2.family.clustered.mu.vcf.gz\
	 --sample-name $target_sample\
	 -O $target_sample.family.clustered.mu.non_site.vcf.gz

	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $target_sample.family.clustered.mu.non_site.vcf.gz\
	 -select "vc.getGenotype('${target_sample}').isHomVar() || vc.getGenotype('${target_sample}').isHet() "\
	 --set-filtered-gt-to-nocall\
	 -O $target_sample.family.clustered.mu.vcf.gz
	gunzip -c $target_sample.family.clustered.mu.vcf.gz > $target_sample.family.clustered.mu.vcf
	##


	##select back variants with hetero + homo.bed 
	cat $target_sample.hetero.bed $target_sample.homo.bed | sort -k 1,1 -k 2n,2 > $target_sample.hetero.homo.bed

	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $vcf_folder/AT.simu.M2.unique.non_neighbor.vcf.gz\
	 --sample-name $target_sample\
	 -L $target_sample.hetero.homo.bed\
	 -O $target_sample.hetero.homo.vcf
	bgzip -c $target_sample.hetero.homo.vcf > $target_sample.hetero.homo.vcf.gz
	tabix -f -p vcf $target_sample.hetero.homo.vcf.gz
	##

	
	#vcf-merge $target_sample.hetero.homo.vcf.gz $target_sample.family.clustered.mu.vcf.gz > $target_sample.all.raw.vcf
	#Merge SNPs and INDELs vcf files into a SNV vcf file
	gatk MergeVcfs\
	 -I $target_sample.hetero.homo.vcf.gz\
	 -I $target_sample.family.clustered.mu.vcf.gz\
	 -O $target_sample.all.raw.vcf
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.all.raw.vcf | sort -k 1,1 -k 2n,2 >  $target_sample.all.bed

	#select back variants with $target_sample.all.bed 
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $vcf_folder/AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
	 --sample-name $target_sample\
	 -L $target_sample.all.bed\
	 -O $target_sample.all.vcf
	bgzip -c $target_sample.all.vcf > $target_sample.all.vcf.gz
	tabix -f -p vcf $target_sample.all.vcf.gz
	##

	##select SBSs and INDEL mutations, respectively
	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $target_sample.all.vcf.gz\
	 -select-type SNP\
	 -O $target_sample.all.snp.vcf
	bgzip -c $target_sample.all.snp.vcf > $target_sample.all.snp.vcf.gz
	tabix -f -p vcf $target_sample.all.snp.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.all.snp.vcf >> $vcf_folder/M2.snp.unsorted.all.bed

	gatk SelectVariants\
	 -R $reference_folder/TAIR10.fa\
	 -V $target_sample.all.vcf.gz\
	 -select-type INDEL\
	 -O $target_sample.all.indel.vcf
	bgzip -c $target_sample.all.indel.vcf > $target_sample.all.indel.vcf.gz
	tabix -f -p vcf $target_sample.all.indel.vcf.gz
	perl $SCRIPT_DIR/Vcf2BED_chr_start_end.pl < $target_sample.all.indel.vcf >> $vcf_folder/M2.indel.unsorted.all.bed
	##



	#output heterozygous mutation.list 
	perl $SCRIPT_DIR/MakeMulationList.pl $target_sample.hetero.vcf $target_sample >> $vcf_folder/$mutation_list_file.hetero.unsort.txt
	#output homozygous mutation.list 
	perl $SCRIPT_DIR/MakeMulationList.pl $target_sample.homo.vcf $target_sample >> $vcf_folder/$mutation_list_file.homo.unsort.txt
	#output familyclustered mutation.list 
	perl $SCRIPT_DIR/MakeMulationList.pl $target_sample.family.clustered.mu.vcf $target_sample >> $vcf_folder/$mutation_list_file.familyclustered.unsort.txt
	#output hetero + homo + familyclustered mutation.list 
	perl $SCRIPT_DIR/MakeMulationList.pl $target_sample.all.vcf $target_sample >> $vcf_folder/$mutation_list_file.all.unsort.txt


	vcf2bed --snvs <  $target_sample.hetero.vcf > $target_sample.snp.hetero.bed
	vcf2bed --insertions < $target_sample.hetero.vcf > $target_sample.insertion.hetero.bed
	vcf2bed --deletions <  $target_sample.hetero.vcf > $target_sample.deletion.hetero.bed
	vcf2bed <  $target_sample.hetero.vcf > $target_sample.hetero.bed	
  
	vcf2bed --snvs <  $target_sample.homo.vcf > $target_sample.snp.homo.bed
	vcf2bed --insertions < $target_sample.homo.vcf > $target_sample.insertion.homo.bed
	vcf2bed --deletions <  $target_sample.homo.vcf > $target_sample.deletion.homo.bed
	vcf2bed  <  $target_sample.homo.vcf > $target_sample.homo.bed
	
	vcf2bed --snvs <  $target_sample.family.clustered.mu.vcf > $target_sample.snp.familyclustered.bed
	vcf2bed --insertions < $target_sample.family.clustered.mu.vcf > $target_sample.insertion.familyclustered.bed
	vcf2bed --deletions < $target_sample.family.clustered.mu.vcf > $target_sample.deletion.familyclustered.bed
	vcf2bed  < $target_sample.family.clustered.mu.vcf > $target_sample.familyclustered.bed

	vcf2bed --snvs <  $target_sample.all.vcf > $target_sample.snp.all.bed
	vcf2bed --insertions < $target_sample.all.vcf > $target_sample.insertion.all.bed
	vcf2bed --deletions <  $target_sample.all.vcf > $target_sample.deletion.all.bed


	no_snp_hetero=`wc -l $target_sample.snp.hetero.bed |awk '{print $1}'`
	no_insertion_hetero=`wc -l $target_sample.insertion.hetero.bed |awk '{print $1}'`
	no_deletion_hetero=`wc -l $target_sample.deletion.hetero.bed |awk '{print $1}'`
	no_indel_hetero=$((no_insertion_hetero + no_deletion_hetero))

	no_snp_homo=`wc -l $target_sample.snp.homo.bed |awk '{print $1}'`
	no_insertion_homo=`wc -l $target_sample.insertion.homo.bed |awk '{print $1}'`
	no_deletion_homo=`wc -l $target_sample.deletion.homo.bed |awk '{print $1}'`
	no_indel_homo=$((no_insertion_homo + no_deletion_homo))
	
	no_snp_familyclustered=`wc -l $target_sample.snp.familyclustered.bed |awk '{print $1}'`
	no_insertion_familyclustered=`wc -l $target_sample.insertion.familyclustered.bed |awk '{print $1}'`
	no_deletion_familyclustered=`wc -l $target_sample.deletion.familyclustered.bed |awk '{print $1}'`
	no_indel_familyclustered=$((no_insertion_familyclustered + no_deletion_familyclustered))

	no_snp_all=`wc -l $target_sample.snp.all.bed |awk '{print $1}'`
	no_insertion_all=`wc -l $target_sample.insertion.all.bed |awk '{print $1}'`
	no_deletion_all=`wc -l $target_sample.deletion.all.bed |awk '{print $1}'`
	no_indel_all=$((no_insertion_all + no_deletion_all))
	
	

	tab_lab="	"
	output_info_hetero=$target_sample$tab_lab$no_snp_hetero$tab_lab$no_indel_hetero$tab_lab$no_insertion_hetero$tab_lab$no_deletion_hetero
	echo $output_info_hetero >> $vcf_folder/$mutation_summary_file_hetero.txt

	output_info_homo=$target_sample$tab_lab$no_snp_homo$tab_lab$no_indel_homo$tab_lab$no_insertion_homo$tab_lab$no_deletion_homo
	echo $output_info_homo >> $vcf_folder/$mutation_summary_file_homo.txt

	output_info_familyclustered=$target_sample$tab_lab$no_snp_familyclustered$tab_lab$no_indel_familyclustered$tab_lab$no_insertion_familyclustered$tab_lab$no_deletion_familyclustered
	echo $output_info_familyclustered >> $vcf_folder/$mutation_summary_file_familyclustered.txt

	output_info_all=$target_sample$tab_lab$no_snp_all$tab_lab$no_indel_all$tab_lab$no_insertion_all$tab_lab$no_deletion_all
	echo $output_info_all >> $vcf_folder//mutation_summary_file_all.txt

	cd ../

done

cd $vcf_folder


cat M2.snp.unsorted.all.bed | sort -k 1,1 -k 2n,2 | uniq >  M2.snp.all.bed 
cat M2.indel.unsorted.all.bed | sort -k 1,1 -k 2n,2 | uniq >  M2.indel.all.bed 


#Sort SNPs + INDELs: heterozygous mutation list 
cat $mutation_list_file.hetero.unsort.txt | sort -k 1,1 -k 2n,2 >  $mutation_list_file.hetero.txt
rm $mutation_list_file.hetero.unsort.txt
#Extract SNPs: heterozygous mutation list
awk '/SNP/' $mutation_list_file.hetero.txt > M2.snp.hetero.list.txt
#Extract INDELs: heterozygous mutation list
awk '/Insertion/ || /Deletion/' $mutation_list_file.hetero.txt > M2.indel.hetero.list.txt

#Sort SNPs + INDELs: homozygous mutation list 
cat $mutation_list_file.homo.unsort.txt | sort -k 1,1 -k 2n,2 >  $mutation_list_file.homo.txt
rm $mutation_list_file.homo.unsort.txt
#Extract SNPs: homozygous mutation list
awk '/SNP/' $mutation_list_file.homo.txt > M2.snp.homo.list.txt
#Extract INDELs: homozygous mutation list
awk '/Insertion/ || /Deletion/' $mutation_list_file.homo.txt > M2.indel.homo.list.txt


#Sort SNPs + INDELs: intra-family shared mutation list 
cat $mutation_list_file.familyclustered.unsort.txt | sort -k 1,1 -k 2n,2 >  $mutation_list_file.familyclustered.txt
rm $mutation_list_file.familyclustered.unsort.txt
#Extract SNPs: intra-family shared mutation list
awk '/SNP/' $mutation_list_file.familyclustered.txt > M2.snp.familyclustered.list.txt
#Extract INDELs: intra-family shared mutation list
awk '/Insertion/ || /Deletion/' $mutation_list_file.familyclustered.txt > M2.indel.familyclustered.list.txt

#Sort SNPs + INDELs: all mutation list 
cat $mutation_list_file.all.unsort.txt | sort -k 1,1 -k 2n,2 >  $mutation_list_file.all.txt
rm $mutation_list_file.all.unsort.txt
#Extract SNPs: all mutation list 
awk '/SNP/' $mutation_list_file.all.txt > M2.snp.all.list.txt
#Extract INDELs: all mutation list 
awk '/Insertion/ || /Deletion/' $mutation_list_file.all.txt > M2.indel.all.list.txt



#transform to bed for final vcf in pipe.12
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.snp.hetero.list.txt | uniq > M2.snp.hetero.bed
#transform to bed for final vcf in pipe.12
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.snp.homo.list.txt | uniq > M2.snp.homo.bed
#transform to bed for final vcf in pipe.12
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.snp.familyclustered.list.txt | uniq > M2.snp.familyclustered.bed
#transform to bed for final vcf in pipe.12
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.snp.all.list.txt | uniq > M2.snp.all.bed


#Output for M2.indel.hetero.vcf
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.indel.hetero.list.txt | uniq > M2.indel.hetero.bed
#Output for M2.indel.homo.vcf
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.indel.homo.list.txt | uniq > M2.indel.homo.bed
#Output for M2.indel.familyclustered.vcf
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.indel.familyclustered.list.txt | uniq > M2.indel.familyclustered.bed
#Output for M2.indel.all.vcf
#perl $SCRIPT_DIR/BioalcidaejdkOut2BED.pl < M2.indel.all.list.txt | uniq > M2.indel.all.bed



#select back variants with hetero.bed 
#gatk SelectVariants\
# -R $reference_folder/TAIR10.fa\
# -V $target_ID.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
# -L M2.indel.hetero.bed\
# --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
# -O M2.indel.hetero.vcf.gz
#bcftools index M2.indel.hetero.vcf.gz

#select back variants with homo.bed 
#gatk SelectVariants\
# -R $reference_folder/TAIR10.fa\
# -V $target_ID.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
# -L M2.indel.homo.bed\
# --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
# -O M2.indel.homo.vcf.gz
#bcftools index M2.indel.homo.vcf.gz

#select back variants with familyclustered.bed 
#gatk SelectVariants\
# -R $reference_folder/TAIR10.fa\
# -V $target_ID.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
# -L M2.indel.familyclustered.bed\
# --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
# -O M2.indel.familyclustered.vcf.gz
#bcftools index M2.indel.familyclustered.vcf.gz

#select back variants with all.bed 
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
 -L M2.snp.all.bed\
 --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
 -O M2.snp.all.vcf.gz
bcftools index M2.snp.all.vcf.gz



#select back variants with all.bed 
gatk SelectVariants\
 -R $reference_folder/TAIR10.fa\
 -V AT.simu.mu.snp.indel.DPfilterNoCall.filtered.vcf.gz\
 -L M2.indel.all.bed\
 --exclude-sample-name $SCRIPT_DIR/Mother_ID.list\
 -O M2.indel.all.vcf.gz
bcftools index M2.indel.all.vcf.gz


cd $SCRIPT_DIR

module unload samtools/1.10
module unload gatk/4.1.7.0
module unload vcftools/0.1.15
module unload bedops/2.4.39
