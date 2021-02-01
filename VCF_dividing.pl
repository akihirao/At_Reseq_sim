#!/usr/bin/perl -i
#VCF_dividing.pl
#perl script for dividing diploidy vcf file into haploidy vcf files 
#by HIRAO Akira



while ($line = <>) {
	chomp $line;
	if($line =~m/^#/){
		print "$line\n";
	}else{
		$rand_prob = rand();

		if($rand_prob >= 0.5){
			print "$line\n";
		}

	}
} 

