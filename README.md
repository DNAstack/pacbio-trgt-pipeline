# PacBio TRGT: Tandem Repeat Genotyper implemented in workflow

This repository contains a workflow for processing PacBio HiFi data and specifically focuses on the [TRGT tool](https://github.com/pacificBiosciences/trgt/) that profiles sequence composition, mosaicism, and CpG methylation of each analyzed repeat. 

Docker image definitions can be explored [in DNAstack's image repository](https://github.com/dnastack/bioinformatics-public-docker-images), or [on Dockerhub](https://hub.docker.com/u/dnastack).


## Workflows

These workflows can be used to process aligned reads.


### Illumina

This workflow is used for processing Illumina (paired-end) monkeypox sequencing data.

#### Workflow inputs:

* Reference genome (FASTA)
* Aligned reads (BAM/SAM)
* The repeat definition file (BED)

#### Workflow outputs:

#### TRGT
* Unsorted VCF file that contains repeat genotypes 
* Unsorted BAM file that contains pieces of HiFi reads that fully span the repeat sequences

#### TRVZ
* A SVG file that contains the pileup read image 


## Running workflows

### Required software

- [Docker](https://docs.docker.com/get-docker/)
- [Cromwell](https://github.com/broadinstitute/cromwell/releases) & Java (8+) OR [miniwdl](https://github.com/chanzuckerberg/miniwdl/releases) & python3

### Running using Cromwell

From the root of the repository, run:

```bash
java -jar /path/to/cromwell.jar run /path/to/workflow.wdl -i /path/to/inputs.json
```

Output and execution files will be located in the `cromwell-executions` directory. When the workflow finishes successfully, it will output JSON (to stdout) specifying the full path to each output file.


### Running using miniwdl

This command assumes you have `miniwdl` available on your command line. If `miniwdl` is not available, try installing using `pip install miniwdl`.

```bash
miniwdl run /path/to/workflow.wdl -i /path/to/inputs.json
```

Output and execution files will be located in a dated directory (e.g. named `20200704_073415_main`). When the workflow finishes successfully, it will output JSON (to stdout) specifying the full path to each output file. 

## Notes / To-Do's

* Improve workflow by possibly adding an alignment step so that FASTQ can be an input. However, researchers cannot choose their own aligner
* Fix the `repeat_id` in `inputs.json` to grep the ID in the `repeat.bed` file instead of feeding it a literal string
* Include an output gcs path?
* Docker push to DNAstack's docker hub
* Test on files other than the [tutorial files](https://github.com/PacificBiosciences/trgt/tree/main/example)
* Docker file is found in [bioinformatics-public-docker-images](https://github.com/DNAstack/bioinformatics-public-docker-images/tree/pacbio-trgt/pacbio_trgt_tools/0.0.1) repo

