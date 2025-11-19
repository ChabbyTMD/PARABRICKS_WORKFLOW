rule fastq_symlinks:
    input:
        unpack(raw_fastq_files)
    output:
        R1="results/fastq_input/{sample}/{lane}_R1.fastq.gz",
        R2="results/fastq_input/{sample}/{lane}_R2.fastq.gz"
    log:
        "logs/fastq_input/{sample}/{sample}_{lane}.log"
    benchmark:
        "benchmarks/fastq_input/{sample}/{sample}_{lane}.txt"
    shell:
        """
        mkdir -p results/fastq_input/{wildcards.sample}
        ln -sf {input.R1} {output.R1}
        ln -sf {input.R2} {output.R2}
        echo "Linked {input.R1} -> {output.R1}" > {log}
        echo "Linked {input.R2} -> {output.R2}" >> {log}
        """

rule fastp:
    input:
        unpack(fastp_input),
    output:
        R1="results/fastp_output/{sample}/{sample}_{lane}_R1.fastq.gz",
        R2="results/fastp_output/{sample}/{sample}_{lane}_R2.fastq.gz",
        summ="results/fastp_output/{sample}/{sample}_{lane}_summary.json"
    log:
        "logs/fastp/{sample}/{sample}_{lane}.log",
    benchmark:
        "benchmarks/fastp/{sample}/{sample}_{lane}.txt",
    conda:
        "workflow/envs/fastp.yaml"
    shell:
        """
        fastp --in1 {input.R1} --in2 {input.R2} \
        --out1 {output.R1} --out2 {output.R2} \
        --thread {threads} \
        --detect_adapter_for_pe \
        -j {output.summ} -h /dev/null \
        &>{log}
        """
