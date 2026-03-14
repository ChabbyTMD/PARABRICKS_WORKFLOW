rule index_reference:
    input:
        reference=config["reference"]
    output:
        indices = expand("results/reference/{ref_acc}.{ext}", ref_acc=config["ref_acc"], ext=["sa", "pac", "bwt", "ann", "amb"]),
    conda:
        "../envs/reference.yaml"
    log:
        "logs/reference/index_reference.log"
    benchmark:
        "benchmarks/reference/index_reference.txt"
    params:
        index_prefix = f"results/reference/{config['ref_acc']}"
    shell:
        """
        mkdir -p results/reference
        bwa index {input.reference}
        samtools faidx {input.reference}
        mv {params.index_prefix}* results/reference/
        """