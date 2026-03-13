rule index_reference:
    input:
        reference=config["reference"]
    output:
        indices = expand("results/reference/{ref_acc}.{ext}", ref_acc=config["ref_acc"], ext=["sa", "pac", "bwt", "ann", "amb"]),
        fai=f"results/reference/{config['ref_acc']}.fai",
    conda:
        "envs/reference.yaml"
    log:
        "logs/reference/index_reference.log"
    benchmark:
        "benchmarks/reference/index_reference.txt"
    params:
        index_prefix = f"results/reference/{config['ref_acc']}"
    shell:
        """
        mkdir -p results/reference
        bwa index -p {params.index_prefix} {input.reference}
        samtools faidx {input.reference}
        cp {input.reference}.fai {output.fai}
        """