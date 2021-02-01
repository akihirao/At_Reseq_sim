#!/usr/bin/perl -i
#FamilyClusterMyu.extract.pl
#by HIRAO Akira


@family_lab = ("mother_1","mother_2","mother_3");

#open (OUT_FAMILY_ALL, ">AT.simu.family.clustered.mu.vcf");

open (OUT_M1, ">$family_lab[0].family.vcf");
open (OUT_M2, ">$family_lab[1].family.vcf");
open (OUT_M3, ">$family_lab[2].family.vcf");
open (OUT_M1_ALL, ">$family_lab[0].family.all.vcf");
open (OUT_M2_ALL, ">$family_lab[1].family.all.vcf");
open (OUT_M3_ALL, ">$family_lab[2].family.all.vcf");

while ($line = <>) {
    chomp $line;
    if($line !~ m/^#/){        
        #($Chr, $end, @info) = split /\s+/, $line;
        ($CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $mother_1, $mother_2, $mother_3, $simu_1_1, $simu_1_2, $simu_1_3, $simu_2_1, $simu_2_2, $simu_2_3, $simu_3_1, $simu_3_2, $simu_3_3)  = split /\s+/, $line;
        ($GT_mother_1, @info) = split /:/, $mother_1;
        ($GT_mother_2, @info) = split /:/, $mother_2;
        ($GT_mother_3, @info) = split /:/, $mother_3;
        ($GT_simu_1_1, @info) = split /:/, $simu_1_1;
        ($GT_simu_1_2, @info) = split /:/, $simu_1_2;
        ($GT_simu_1_3, @info) = split /:/, $simu_1_3;
        ($GT_simu_2_1, @info) = split /:/, $simu_2_1;
        ($GT_simu_2_2, @info) = split /:/, $simu_2_2;
        ($GT_simu_2_3, @info) = split /:/, $simu_2_3;
        ($GT_simu_3_1, @info) = split /:/, $simu_3_1;
        ($GT_simu_3_2, @info) = split /:/, $simu_3_2;
        ($GT_simu_3_3, @info) = split /:/, $simu_3_3;

        $GT_simu_1_1_a = substr($GT_simu_1_1,0,1); $GT_simu_1_1_b = substr($GT_simu_1_1,2,1); $GT_sum_simu_1_1 = $GT_simu_1_1_a + $GT_simu_1_1_b;if($GT_simu_1_1_b > 0) {$GT_simu_1_1_Alt = 1}else{$GT_simu_1_1_Alt = 0};
        $GT_simu_1_2_a = substr($GT_simu_1_2,0,1); $GT_simu_1_2_b = substr($GT_simu_1_2,2,1); $GT_sum_simu_1_2 = $GT_simu_1_2_a + $GT_simu_1_2_b;if($GT_simu_1_2_b > 0) {$GT_simu_1_2_Alt = 1}else{$GT_simu_1_2_Alt = 0};
        $GT_simu_1_3_a = substr($GT_simu_1_3,0,1); $GT_simu_1_3_b = substr($GT_simu_1_3,2,1); $GT_sum_simu_1_3 = $GT_simu_1_3_a + $GT_simu_1_3_b;if($GT_simu_1_3_b > 0) {$GT_simu_1_3_Alt = 1}else{$GT_simu_1_3_Alt = 0};
        $GT_mother_1_a = substr($GT_mother_1,0,1); $GT_mother_1_b = substr($GT_mother_1,2,1); $GT_sum_mother_1 = $GT_mother_1_a + $GT_mother_1_b;if($GT_mother_1_b > 0) {$GT_mother_1_Alt = 1}else{$GT_mother_1_Alt = 0};

        $GT_simu_2_1_a = substr($GT_simu_2_1,0,1); $GT_simu_2_1_b = substr($GT_simu_2_1,2,1); $GT_sum_simu_2_1 = $GT_simu_2_1_a + $GT_simu_2_1_b;if($GT_simu_2_1_b > 0) {$GT_simu_2_1_Alt = 1}else{$GT_simu_2_1_Alt = 0};
        $GT_simu_2_2_a = substr($GT_simu_2_2,0,1); $GT_simu_2_2_b = substr($GT_simu_2_2,2,1); $GT_sum_simu_2_2 = $GT_simu_2_2_a + $GT_simu_2_2_b;if($GT_simu_2_2_b > 0) {$GT_simu_2_2_Alt = 1}else{$GT_simu_2_2_Alt = 0};
        $GT_simu_2_3_a = substr($GT_simu_2_3,0,1); $GT_simu_2_3_b = substr($GT_simu_2_3,2,1); $GT_sum_simu_2_3 = $GT_simu_2_3_a + $GT_simu_2_3_b;if($GT_simu_2_3_b > 0) {$GT_simu_2_3_Alt = 1}else{$GT_simu_2_3_Alt = 0};
        $GT_mother_2_a = substr($GT_mother_2,0,1); $GT_mother_2_b = substr($GT_mother_2,2,1); $GT_sum_mother_2 = $GT_mother_2_a + $GT_mother_2_b;if($GT_mother_2_b > 0) {$GT_mother_2_Alt = 1}else{$GT_mother_2_Alt = 0};

        $GT_simu_3_1_a = substr($GT_simu_3_1,0,1); $GT_simu_3_1_b = substr($GT_simu_3_1,2,1); $GT_sum_simu_3_1 = $GT_simu_3_1_a + $GT_simu_3_1_b;if($GT_simu_3_1_b > 0) {$GT_simu_3_1_Alt = 1}else{$GT_simu_3_1_Alt = 0};
        $GT_simu_3_2_a = substr($GT_simu_3_2,0,1); $GT_simu_3_2_b = substr($GT_simu_3_2,2,1); $GT_sum_simu_3_2 = $GT_simu_3_2_a + $GT_simu_3_2_b;if($GT_simu_3_2_b > 0) {$GT_simu_3_2_Alt = 1}else{$GT_simu_3_2_Alt = 0};
        $GT_simu_3_3_a = substr($GT_simu_3_3,0,1); $GT_simu_3_3_b = substr($GT_simu_3_3,2,1); $GT_sum_simu_3_3 = $GT_simu_3_3_a + $GT_simu_3_3_b;if($GT_simu_3_3_b > 0) {$GT_simu_3_3_Alt = 1}else{$GT_simu_3_3_Alt = 0};
        $GT_mother_3_a = substr($GT_mother_3,0,1); $GT_mother_3_b = substr($GT_mother_3,2,1); $GT_sum_mother_3 = $GT_mother_3_a + $GT_mother_3_b;if($GT_mother_3_b > 0) {$GT_mother_3_Alt = 1}else{$GT_mother_3_Alt = 0};

#        print $GT_A011_Alt, "\n";

        @GT_12indiv_vec = ($GT_sum_simu_1_1, $GT_sum_simu_1_2, $GT_sum_simu_1_3, $GT_sum_simu_2_1, $GT_sum_simu_2_2, $GT_sum_simu_2_3, $GT_sum_simu_3_1, $GT_sum_simu_3_2, $GT_sum_simu_3_3, $GT_sum_mother_1, $GT_sum_mother_2, $GT_sum_mother_3);
        @GT_12indiv_alt = ($GT_simu_1_1_Alt, $GT_simu_1_2_Alt, $GT_simu_1_3_Alt, $GT_simu_2_1_Alt, $GT_simu_2_2_Alt, $GT_simu_2_3_Alt, $GT_simu_3_1_Alt, $GT_simu_3_2_Alt, $GT_simu_3_3_Alt, $GT_mother_1_Alt, $GT_mother_2_Alt, $GT_mother_3_Alt);
    

        $M1_mu = 0; $non_M1_mu = 0;  #initializing zero
        @M1_non = @GT_12indiv_alt; @M1_fam = splice (@M1_non,0,3);$M1_mu += $_ for @M1_fam;$non_M1_mu += $_ for @M1_non;
        if($M1_mu >= 2 and $non_M1_mu == 0 and $GT_sum_mother_1 == 0){
            print $line, "\n";
            print OUT_M1 $line, "\n";

        }
        if($M1_mu == 3 and $non_M1_mu == 0 and $GT_sum_mother_1 == 0){
            print OUT_M1_ALL $line, "\n";
        }
  


        $M2_mu = 0; $non_M2_mu = 0;  #initializing zero
        @M2_non = @GT_12indiv_alt; @M2_fam = splice (@M2_non,3,3);$M2_mu += $_ for @M2_fam;$non_M2_mu += $_ for @M2_non;
        if($M2_mu >= 2 and $non_M2_mu == 0 and $GT_sum_mother_2 == 0){
            print $line, "\n";
             print OUT_M2 $line, "\n";
       }
        if($M2_mu == 3 and $non_M2_mu == 0 and $GT_sum_mother_2 == 0){
            print OUT_M2_ALL $line, "\n";
        }
  
    

        $M3_mu = 0; $non_M3_mu = 0;  #initializing zero
        @M3_non = @GT_12indiv_alt; @M3_fam = splice (@M3_non,6,3);$M3_mu += $_ for @M3_fam;$non_M3_mu += $_ for @M3_non;
        if($M3_mu >= 2 and $non_M3_mu == 0 and $GT_sum_mother_3 == 0){
            print $line, "\n";
            print OUT_M3 $line, "\n";
       }
        if($M3_mu == 3 and $non_M3_mu == 0 and $GT_sum_mother_3 == 0){
            print OUT_M3_ALL $line, "\n";
        }
  
 
    }else{

#       print OUT_FAMILY_ALL $line, "\n";
        print $line, "\n";

        print OUT_M1 $line, "\n";
        print OUT_M2 $line, "\n";
        print OUT_M3 $line, "\n";

        print OUT_M1_ALL $line, "\n";
        print OUT_M2_ALL $line, "\n";
        print OUT_M3_ALL $line, "\n";

    }

}

close (OUT_M1);
close (OUT_M2);
close (OUT_M3);

close (OUT_M1_ALL);
close (OUT_M2_ALL);
close (OUT_M3_ALL);
