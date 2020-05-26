#!/bin/bash -i
#Sim.11.VCFCompare.sh
#by HIRAO Akira


reference_folder=/zfs/Arabidopsis/Reference_v1.1

module load samtools/1.10
module load gatk/4.1.7.0
module load vcftools/0.1.15

output_folder=/zfs/Arabidopsis/work/mutation_sim/vcf_out
main_folder=/zfs/Arabidopsis/work/mutation_sim/
cd $output_folder


for i in `seq 1 3`;
do

	echo -n >| $output_folder/snp_mutation_summary.$i.txt
	echo -n >| $output_folder/indel_mutation_summary.$i.txt

	#identifying unique SNPs with using bioalcidaejdk.jar
	java -jar /usr/local/jvarkit/dist/bioalcidaejdk.jar \
	-e 'stream().forEach(V->{final List<Genotype> L=V.getGenotypes().stream().filter(G->G.isHet() || G.isHomVar()).collect(Collectors.toList());if(L.size()!=1) return;final Genotype g=L.get(0);println(V.getContig()+" "+V.getStart()+" "+V.getReference()+" "+g.getSampleName()+" "+g.getAlleles());});' $output_folder/AT.simu.$i.snp.DPfilterNoCall.vcf > $output_folder/AT.simu.$i.snp.mutation.list.txt
	#identifying unique INDELs with using bioalcidaejdk.jar
	java -jar /usr/local/jvarkit/dist/bioalcidaejdk.jar \
	-e 'stream().forEach(V->{final List<Genotype> L=V.getGenotypes().stream().filter(G->G.isHet() || G.isHomVar()).collect(Collectors.toList());if(L.size()!=1) return;final Genotype g=L.get(0);println(V.getContig()+" "+V.getStart()+" "+V.getReference()+" "+g.getSampleName()+" "+g.getAlleles());});' $output_folder/AT.simu.$i.indel.DPfilterNoCall.vcf > $output_folder/AT.simu.$i.indel.mutation.list.txt


	#Selection unique snps
	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.snp.DPfilterNoCall.vcf \
	-select 'set == "Intersection";' \
	-invertSelect \
	-O AT.simu.$i.snp.unique.vcf

	#Selection unique indels
	gatk SelectVariants \
	-R $reference_folder/TAIR10.fa \
	-V AT.simu.$i.indel.DPfilterNoCall.vcf \
	-select 'set == "Intersection";' \
	-invertSelect \
	-O AT.simu.$i.indel.unique.vcf


	for j in $(seq 1 3) #roop for serial number 1-3
	do

		underbar_lab="_"
		target_header="simu"
		target=$target_header$underbar_lab$i$underbar_lab$j

		echo $target

		gatk SelectVariants \
		-R $reference_folder/TAIR10.fa \
		-V AT.simu.$i.snp.unique.vcf \
		--sample-name $target \
		-select 'vc.getHetCount() == 1' \
		-O $main_folder/vcf_out/$target.snp.unique.vcf \

		no_snp_mutation=$(grep -v "^#" $main_folder/vcf_out/$target.snp.unique.vcf | wc -l)
		tab_lab="	"
		no_snp_mutation_output=$target$tab_lab$no_snp_mutation
		echo  $no_snp_mutation_output >> $output_folder/snp_mutation_summary.$i.txt


		gatk SelectVariants \
		-R $reference_folder/TAIR10.fa \
		-V AT.simu.$i.indel.unique.vcf \
		--sample-name $target \
		-select 'vc.getHetCount() == 1' \
		-O $main_folder/vcf_out/$target.indel.unique.vcf \

		no_indel_mutation=$(grep -v "^#" $main_folder/vcf_out/$target.indel.unique.vcf | wc -l)
		tab_lab="	"
		no_indel_mutation_output=$target$tab_lab$no_indel_mutation
		echo  $no_indel_mutation_output >> $output_folder/indel_mutation_summary.$i.txt

	done

done



module unload samtools/1.10
module unload gatk/4.1.7.0
module unload vcftools/0.1.15