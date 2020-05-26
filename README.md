# Simulation of DNA mutation events in <i>Arabidopsis thaliana</i>
Bioinformatics pipeline for muntant simulation and validation of variant calling workflow in resequences of <i>Arabidopsis thaliana</i>
 

## Arabidopsis thaliana genomic resources
TAIR10 genomic sequences were downloaded from the TAIR FTP site. 


# Requirement

* simuG: a general-purpose genome simulator (https://github.com/yjx1217/simuG)
* sandy: a next-generation sequencing read simulator (https://galantelab.github.io/sandy)
* samtools: Tools for manipulating NGS data (https://github.com/samtools/samtools)
* vcftools: A set of tools for working with VCF files (https://github.com/vcftools/vcftools)
* BWA: Burrow-Wheeler Aligner (http://bio-bwa.sourceforge.net) 
* gatk: Genome Analysis Toolkit (https://gatk.broadinstitute.org/)
* BioAlcidaeJdk: java-based version of awk for bioinformatics (http://lindenb.github.io/jvarkit/BioAlcidaeJdk.html)


The environments under CentOS 7.5 are tested. The versions of tools used are documented in a series of shell scripts.



# Flowchart
 
Install Pyxel with pip command.
 
```bash
pip install pyxel
```



# Usage
Run a series of the shell scripts in the order listes after changing paths according to your environemt:
 
```bash
Sim.01.Col6909.genome.sh
Sim.02.Make.mother.reads.sh
Sim.03.Make.mutants.reads.sh
...
Sim.13.VCFCompare.sh
```



# Note
 

