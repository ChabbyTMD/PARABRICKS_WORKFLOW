# A Simple Parabricks Germline Workflow

This is a convenient wrapper for the Nvidia Parabricks Germline workflow. Designed according to GATK best practices, the germline workflow handles read alignment, base score quality recalibration and variant calling accelerated by Nvida GPUs. 

This workflow is designed to flexibly feed into germline sequence data from one or multiple lanes. The user need only to supply a correctly formatted sample sheet, an example of which is provided [here](config/samples.csv). 



## Quick Start

Pull the latest docker image of the workflow [here](https://hub.docker.com/repository/docker/chabbytmd1/parabricks-snakemake/general)

### Workflow Setup.

Provide the path to an adequately formatted sample sheet to the `samplesheet` directive and the path to the reference genome in the `reference` directive in the [`config/config.yaml`](config/config.yaml) file.

The sample sheet must contain valid relative or absolute paths to your paired-end sequence reads available on your system. Forward reads in `fq1` and reverse reads in the `fq2` column respectively.

A sample sheet constructor helper script is currently under development. An alpha version is available in the [utilities directory](utilities/build_sample_sheet.sh)


In case you have an NCBI RefSeq Accession for your species, please provide it to the `ref_acc` directive.

## Workflow Execution

Perform a dry run to ensure the workflow detects your samples.

```bash
snakemake -np --cores all --workflow-profile workflow-profiles/default/

```

Once the dry run is successfully executed, perform a wet run with

```bash
snakemake -p --cores all --workflow-profile workflow-profiles/default/

```

