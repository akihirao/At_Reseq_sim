# Simulation of DNA mutation events in Arabidopsis thaliana
Bioinformatics pipeline for muntant simulation and validation of variant calling workflow
 
 
# Requirement

* simuG: a general-purpose genome simulator (https://github.com/yjx1217/simuG)
* sandy: a next-generation sequencing read simulator (https://galantelab.github.io/sandy)
* samtools: Tools for manipulating NGS data (https://github.com/samtools/samtools)
* vcftools: A set of tools for working with VCF files (https://github.com/vcftools/vcftools)
* BWA: Burrow-Wheeler Aligner (http://bio-bwa.sourceforge.net) 
* gatk: Genome Analysis Toolkit (https://gatk.broadinstitute.org/)
* BioAlcidaeJdk: java-based version of awk for bioinformatics (http://lindenb.github.io/jvarkit/BioAlcidaeJdk.html)


# Flowchart
 
Install Pyxel with pip command.
 
```bash
pip install pyxel
```


# Usage
 
Run a series of the shell scripts in the order listes :
 
```bash
Sim.01.Col6909.genome.sh
```
```bash
Sim.02.Make.mother.reads.sh
```
...
Sim.13.VCFCompare.sh

 
# Note
 
Environments under CentOS ver 7.5.1804 is tested.
