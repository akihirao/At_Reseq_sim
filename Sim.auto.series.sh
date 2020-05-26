#!/bin/bash -i
#Sim.auto.series.sh
#by HIRAO Akira

./Sim.00.Make.mother.TAIR10.sh
./Sim.01.Make.mutation.TAIR10.sh
./Sim.02.Map.sh
./Sim.03.MarkduplicatesSpark.sh
./Sim.04.BaseRecalibrator.sh
./Sim.05.ApplyBQSR.sh
./Sim.06.HaplotypeCaller.sh
./Sim.07.GenomicsDBImport_GVCF.sh
./Sim.08.GenotypeGVCF.sh
./Sim.09.SelectVariants.sh
./Sim.10.VariantFiltration.sh
./Sim.11.VCFCompare.sh
