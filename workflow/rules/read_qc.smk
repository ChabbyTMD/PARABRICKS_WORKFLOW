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
    shell:
        """
        fastp --in1 {input.R1} --in2 {input.R2} \
        --out1 {output.R1} --out2 {output.R2} \
        --thread {threads} \
        --detect_adapter_for_pe \
        -j {output.summ} -h /dev/null \
        &>{log}
        """
