# <i>In Silico</i> mutation simulation of whole genome sequence in <i>Arabidopsis thaliana</i>
Bioinformatics pipeline for germline mutation simulation and mutation identification from whole genome sequencing data of <i>Arabidopsis thaliana</i>
 

## Requirement

* simuG: a general-purpose genome simulator (https://github.com/yjx1217/simuG)
* sandy: a next-generation sequencing read simulator (https://galantelab.github.io/sandy)
* samtools: Tools for manipulating NGS data (https://github.com/samtools/samtools)
* vcftools: A set of tools for working with VCF files (https://github.com/vcftools/vcftools)
* BWA: Burrow-Wheeler Aligner (http://bio-bwa.sourceforge.net) 
* gatk: Genome Analysis Toolkit (https://gatk.broadinstitute.org/)
* BioAlcidaeJdk: java-based version of awk for bioinformatics (http://lindenb.github.io/jvarkit/BioAlcidaeJdk.html)


The environment under CentOS 7.5 is tested. The versions of the tools used are documented in a series of shell scripts listed.


## <i>Arabidopsis thaliana</i> genomic resources
TAIR10 genomic sequences were downloaded from the TAIR FTP site. The variants of Col-0 ecotype were download from the 1001 Genomes (https://1001genomes.org).


## Initial setting
* The number of mutation per nuclear genome: 2000 SNPs, 1000 INDELs
* Fastq-file coverage: 50x on nuclear genome, 200x on chloroplast genome, 6000x on mitochondoria genome<sup>*1</sup>

<sup>*1</sup>: The coverage values were derived from our real data.


## Flowchart
 
<p align="left">
  <img src="https://github.com/akihirao/At_Reseq_sim/blob/master/images/At_Reseq_sim.workflow.jpeg"/>
</p>



## Usage
Run a series of the shell scripts in the order listed after changing paths according to your environemt:
 
```bash
Pipe.01.Col6909.genome.sh
Pipe.02.Make.mother.reads.sh
Pipe.03.Make.mutants.reads.sh
...
Pipe.12.MutationIdentification.sh
```



## Note
 
This project is currently under development.
Thank you!
