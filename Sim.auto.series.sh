#!/bin/bash -i
#Pipe.auto.series.sh
#by HIRAO Akira

#./Pipe.01.Mather.genome.sh
#./Pipe.02.Make.mother.reads.sh
./Pipe.03.Make.mutants.reads.sh
./Pipe.04.Map.sh
./Pipe.05.MarkduplicatesSpark.sh
./Pipe.06.BaseRecalibration.sh
./Pipe.07.HaplotypeCaller.sh
./Pipe.08.GenomicsDBImport_GVCF.sh
./Pipe.09.GenotypeGVCF.sh
./Pipe.10.SelectVariants.sh
./Pipe.11.VariantFiltration.sh
#./Pipe.12.IdintifyingMutation.sh
