rule index_reference:
    input:
        reference=config["reference"]
    output:
        indices = expand("results/reference/{ref_acc}.{ext}", ref_acc=config["ref_acc"], ext=["sa", "pac", "bwt", "ann", "amb"]),
        fai = f"results/reference/{config['ref_acc']}.fai",
    conda:
        "../envs/reference.yaml"
    log:
        "logs/reference/index_reference.log"
    benchmark:
        "benchmarks/reference/index_reference.txt"
    params:
        ref_prefix = f"results/reference/{config['ref_acc']}"
    shell:
        """
        mkdir -p results/reference
        mv {input.reference} {params.ref_prefix}.fasta
        bwa index {params.ref_prefix}.fasta
        samtools faidx {params.ref_prefix}.fasta
        """