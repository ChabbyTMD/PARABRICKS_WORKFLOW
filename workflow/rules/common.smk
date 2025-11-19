import sys
import os
import random
import string
import json
import pandas as pd
from pathlib import Path



def parse_sample_sheet(config):
    """Parse sample sheet CSV file."""
    return pd.read_csv(config["samplesheet"])


# def get_fq_params(wildcards):
#     """
#     Extract all fq1 and fq2 file pairs for a given sample and format them
#     as --in-fq parameters for pb_germline rule.
    
#     Args:
#         wildcards: Snakemake wildcards object containing 'sample'
#         samples: DataFrame from parse_sample_sheet
    
#     Returns:
#         String of formatted --in-fq parameters for all lanes of the sample
#     """
#     sample_data = samples[samples["sample"] == wildcards.sample]
#     fq_params = []
    
#     for _, row in sample_data.iterrows():
#         fq_params.append(f"--in-fq {row['fq1']} {row['fq2']}")
    
#     return " \\\n    ".join(fq_params)


def fastp_input(wildcards):
    """
    Get all raw fq1 and fq2 files for a given sample as input to fastp rule.
    """
    lane = samples.loc[samples["lane"] == wildcards.lane]
    R1 = f"results/fastq_input/{wildcards.sample}/{wildcards.lane}_R1.fastq.gz"
    R2 = f"results/fastq_input/{wildcards.sample}/{wildcards.lane}_R2.fastq.gz"
    if "fq1" in samples.columns and "fq2" in samples.columns:
        if lane["fq1"].notnull().any() and lane["fq2"].notnull().any():
            R1 = lane.fq1.item()
            R2 = lane.fq2.item()
            if os.path.exists(R1) and os.path.exists(R2):
                return {"R1": R1, "R2": R2}
            else:
                raise WorkflowError(f"FASTQ files for sample {wildcards.sample}, lane {wildcards.lane} do not exist: {R1}, {R2}")
        else:
            return {"R1": R1, "R2": R2}
    else:
        return {"R1": R1, "R2": R2}

def pb_germline_fq_files(wildcards):
    """
    Extract all QCed fq1 and fq2 file pairs for a given sample as input to pb_germline pipeline.
    """
    sample_data = samples[samples["sample"] == wildcards.sample]
    fq_params = []
    
    for _, row in sample_data.iterrows():
        fq_params.append(f"--in-fq results/fastp_output/{row['sample']}/{row['sample']}_{row['lane']}_R1.fastq.gz results/fastp_output/{row['sample']}/{row['sample']}_{row['lane']}_R2.fastq.gz")
    
    return " \\\n    ".join(fq_params)



def parabricks_output(wildcards):
    """
    All expected output files from Parabricks workflow.
    """
    output = []
    unique_samples = samples["sample"].unique()
    output.extend(expand("results/BAMs/{sample}.bam", sample=unique_samples))
    output.extend(expand("results/VCFs/{sample}.vcf.gz", sample=unique_samples))
    return output