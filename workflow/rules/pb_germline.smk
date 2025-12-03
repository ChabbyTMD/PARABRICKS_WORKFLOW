ruleorder:
    pb_germline > vcf_fix_header

rule pb_germline:
    """
    Run the Parabricks Germline Variant Calling Pipeline using the filtered FASTQ files from fastp as input. Can work with single or multiple lanes per sample.
    Outputs per-sample BAM and VCF files.

    #TODO: Implement haplotyper caller options
     Performance tuning options specified in this rule
    --gpuwrite             Use one GPU to accelerate writing final BAM/CRAM.
    --gpusort              Use GPUs to accelerate sorting and marking.
    --run-partition        Divide the whole genome into multiple partitions and run multiple processes at the same time, each on one partition. This can only be ran on multiple GPUS at least 2 and from then on, multiples of 2.
    """
    input:
        reference=config["reference"],
    output:
        bam = "results/BAMs/{sample}.bam",
        vcf = temp("results/VCFs/{sample}.vcf"),
    log:
        "logs/pb_germline/{sample}/{sample}_pb_germline.log",
    params:
        fq_params = lambda wildcards: pb_germline_fq_files(wildcards),
    benchmark:
        "benchmarks/pb_germline/{sample}.txt",
    shell:
        """
        pbrun germline \
            --ref {input.reference} \
            {params.fq_params} \
            --out-bam {output.bam} \
            --out-variants {output.vcf} \
            --logfile {log} \
            --verbose \
            --memory-limit {resources.memory} \
            --gpusort \
            --gpuwrite \
        """
# TODO: sort and index sample vcf files
rule vcf_sort_index:
    """
    Sort VCF file with bcftools and index with tabix.
    """
    input:
        vcf = "results/VCFs/{sample}.fixed.vcf"
    output:
        vcf_sorted = "results/VCFs/{sample}.sorted.vcf.gz",
        vcf_index = "results/VCFs/{sample}.sorted.vcf.gz.tbi"
    conda:
        "../envs/htslib.yaml"
    shell:
        """
        bcftools sort {input.vcf} -Oz -o {output.vcf_sorted}
        tabix -p vcf {output.vcf_sorted}
        """


rule vcf_fix_header:
    """
    Replace the generic entry "sample" with sample ID in the VCF header.
    """
    input:
        vcf_in = "results/VCFs/{sample}.vcf"
    output:
        vcf_out = temp("results/VCFs/{sample}.fixed.vcf")
    shell:
        """
        awk 'BEGIN{{OFS="\t"}} /^#CHROM/{{$NF = "{wildcards.sample}"; print; next}} {{print}}' {input.vcf_in} > {output.vcf_out}
        """

# TODO: Implement rule to merge all sample VCFs into one multi-sample VCF

rule merge_vcfs:
    """
    Merge all per-sample VCFs into a single multi-sample VCF using bcftools merge.
    """
    input:
        vcfs = lambda wildcards: get_all_sample_vcfs(),
    output:
        merged_vcf = "results/VCFs/merged_samples.vcf.gz",
        merged_index = "results/VCFs/merged_samples.vcf.gz.tbi"
    conda:
        "../envs/htslib.yaml"
    shell:
        """
        bcftools merge {input.vcfs} -Oz -o {output.merged_vcf}
        tabix -p vcf {output.merged_vcf}
        """