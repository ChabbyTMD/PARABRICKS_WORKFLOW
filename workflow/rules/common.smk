import sys
import os
import random
import string
import json
import pandas as pd
from pathlib import Path
from snakemake.exceptions import WorkflowError



def parse_sample_sheet(config):
    """Parse sample sheet CSV file."""
    
    samplesheet_path = config["samplesheet"]
    if not os.path.exists(samplesheet_path):
        raise WorkflowError(f"Sample sheet file not found: {samplesheet_path}")
    
    return pd.read_csv(samplesheet_path)


def raw_fastq_files(wildcards):
    """Return original raw FASTQ file paths for a sample/lane with validation.

    Handles potential type mismatches between numeric lane column and string wildcard.
    """
    lane_row = samples[(samples["sample"].astype(str) == str(wildcards.sample)) & (samples["lane"].astype(str) == str(wildcards.lane))]
    if lane_row.empty:
        available = ",".join(sorted(samples[samples["sample"].astype(str) == str(wildcards.sample)]["lane"].astype(str).unique()))
        raise WorkflowError(
            f"No entry found in samplesheet for sample {wildcards.sample} lane {wildcards.lane}. Available lanes for sample: {available if available else 'NONE'}"
        )
    if not {"fq1", "fq2"}.issubset(lane_row.columns):
        raise WorkflowError("samplesheet must contain fq1 and fq2 columns")
    R1 = lane_row.fq1.iloc[0]
    R2 = lane_row.fq2.iloc[0]
    if not (os.path.exists(R1) and os.path.exists(R2)):
        raise WorkflowError(f"Raw FASTQ files missing for sample {wildcards.sample} lane {wildcards.lane}: {R1}, {R2}")
    return {"R1": R1, "R2": R2}

def fastp_input(wildcards):
    """Always return symlink paths to be generated for fastp input."""
    return {
        "R1": f"results/fastq_input/{wildcards.sample}/{wildcards.lane}_R1.fastq.gz",
        "R2": f"results/fastq_input/{wildcards.sample}/{wildcards.lane}_R2.fastq.gz",
    }

def pb_germline_fq_files(wildcards):
    """
    Extract all QCed fq1 and fq2 file pairs for a given sample as input to pb_germline pipeline.
    """
    sample_data = samples[samples["sample"] == wildcards.sample]
    fq_params = []

    for _, row in sample_data.iterrows():
        fq_params.append(
            f"--in-fq results/fastp_output/{row['sample']}/{row['sample']}_{row['lane']}_R1.fastq.gz results/fastp_output/{row['sample']}/{row['sample']}_{row['lane']}_R2.fastq.gz"
        )

    return " \\\n    ".join(fq_params)


def get_all_sample_vcfs():
    """Get all sample VCF files for merging."""
    unique_samples = samples["sample"].unique()
    return expand("results/VCFs/{sample}.sorted.vcf.gz", sample=unique_samples)


def parabricks_output():
    """
    All expected final outputs from Parabricks workflow.
    - Per-sample BAMs
    - Merged multi-sample VCF (bgzipped)
    """
    output = []
    unique_samples = samples["sample"].unique()
    output.extend(expand("results/BAMs/{sample}.bam", sample=unique_samples))
    output.append("results/VCFs/merged_samples.vcf.gz")
    return output
    