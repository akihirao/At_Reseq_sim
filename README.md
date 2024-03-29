# <i>In Silico</i> mutation simulation of whole genome sequence in <i>Arabidopsis thaliana</i>
Bioinformatics pipeline for germline mutation simulation and mutation identification in whole genome sequencing data of <i>Arabidopsis thaliana</i>
 

## Requirement

* simuG: a general-purpose genome simulator (https://github.com/yjx1217/simuG)
* sandy: a next-generation sequencing read simulator (https://galantelab.github.io/sandy)
* samtools: Tools for manipulating NGS data (https://github.com/samtools/samtools)
* vcftools: A set of tools for working with VCF files (https://github.com/vcftools/vcftools)
* BWA: Burrow-Wheeler Aligner (http://bio-bwa.sourceforge.net) 
* GATK: Genome Analysis Toolkit (https://gatk.broadinstitute.org/)
* BioAlcidaeJdk: java-based version of awk for bioinformatics (http://lindenb.github.io/jvarkit/BioAlcidaeJdk.html)


The environment under CentOS 7.5 is tested. The versions of the tools used are documented in a series of shell scripts listed.


## <i>Arabidopsis thaliana</i> genomic resources
TAIR10 genomic sequences were downloaded from the TAIR FTP site. The variants of Col-0 ecotype were download from the 1001 Genomes (https://1001genomes.org).


## Initial setting
* The number of mutations per nuclear diploid genome: 2000 SBSs, 1000 INDELs
* Read coverage: 50x on nuclear genome (the value was derived from our real data)
* A single simulation procedure generates WGS data of a mather and three self-fertilized offspring with mutations.
* A total of three families (e.g. three mathers and their nine offspring) are jointly handled for variant calling.



## Flowchart
 
<p align="left">
  <img src="https://github.com/akihirao/At_Reseq_sim/blob/master/images/At_Reseq_sim.workflow.jpeg" width="75%" height="75%"/>
</p>



## Usage
Run a series of the shell scripts in the order listed after changing paths according to your environemt:
 
```bash
Pipe.01.Mather.genome.sh
Pipe.02.Make.mother.reads.sh
Pipe.03.Make.mutants.reads.sh
...
Pipe.12.MutationIdentification.sh
```



## Reference

Hirao AS, Watanabe Y, Hasegawa Y, Takagi T, Ueno S, Kaneko S (2022) Mutational effects of chronic gamma radiation throughout the life cycle of Arabidopsis thaliana: insight into radiosensitivity in the reproductive stage. Science of the Total Environment. https://doi.org/10.1016/j.scitotenv.2022.156224
