rule pb_germline:
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
            --memory-limit {resources.memory}
        """

rule vcf_compress:
    input:
        vcf_in = "results/VCFs/{sample}.vcf"
    output:
        vcf_out = "results/VCFs/{sample}.vcf.gz"
    shell:
        """
        bgzip {input.vcf_in} > {output.vcf_out}
        """