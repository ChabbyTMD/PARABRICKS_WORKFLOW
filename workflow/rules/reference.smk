rule index_reference:
    input:
        reference=reference
    output:
        indices = expand("results/reference/{ref_acc}.{ext}", ref_acc=config["ref_acc"], ext=["sa", "pac", "bwt", "ann", "amb"]),
        fai="results/reference.fasta.fai",
    conda:
        "envs/reference.yaml"
    log:
        "logs/reference/index_reference.log"
    benchmark:
        "benchmarks/reference/index_reference.txt"
    shell:
        """
        bwa index {input.reference}
        samtools faidx {input.reference}
        """