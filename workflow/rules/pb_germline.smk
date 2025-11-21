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
        fastq=lambda wildcards: get_fastp_outputs(wildcards),
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

rule vcf_compress:
    input:
        vcf_in = "results/VCFs/{sample}.vcf"
    output:
        vcf_out = "results/VCFs/{sample}.vcf.gz"
    conda:
        "../envs/htslib.yaml"
    shell:
        """
        bgzip -f {input.vcf_in} > {output.vcf_out}
        """