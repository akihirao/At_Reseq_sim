#!/usr/bin/perl -i
#VCF_dividing.pl
#perl script for dividing diploidy vcf file into haploidy vcf files 
#by HIRAO Akira


if (@ARGV < 1){
	die "USAG: perl VCF_dividing.pl input.vcf/n";
}

$input = shift @ARGV;

open (INFILE, $input);

open (FILE1, ">haploid1.mutant.SNP_INDEL.vcf");
open (FILE2, ">haploid2.mutant.SNP_INDEL.vcf");

while ($line = <INFILE>) {
	chomp $line;
	if($line =~m/^#/){
		print FILE1 "$line\n";
		print FILE2 "$line\n";
	}else{
		$prob_a = rand();
		$prob_b = rand();

		if($prob_a >= 0.5){
			print FILE1 "$line\n";
		}

		if($prob_b >= 0.5){
			print FILE2 "$line\n";
		}

	}
} 

close (FILE1);
close (FILE2);
