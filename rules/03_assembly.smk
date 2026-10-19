# rules/assembly.smk
# De novo genome assembly using SPAdes
# --isolate flag is optimised for single bacterial isolate WGS data
# Contigs less than 500bp are filtered out after assembly

rule spades_assembly:
    input:
        r1 = "data/trimmed/{sample}_1.trim.fastq.gz",
        r2 = "data/trimmed/{sample}_2.trim.fastq.gz",
    output:
        contigs = "results/assembly/{sample}/contigs.fasta",
        filtered = "results/assembly/{sample}/contigs_filtered.fasta",
    params:
        outdir = "results/assembly/{sample}",
    log:
        "logs/spades/{sample}.log",
    threads: 4
    shell:
        """
        mkdir -p logs/spades
        spades.py \
            -1 {input.r1} \
            -2 {input.r2} \
            --isolate \
            --threads {threads} \
            -o {params.outdir} \
            > {log} 2>&1

        awk '/^>/{{if(seq && length(seq)>=500) print header"\\n"seq; \
            header=$0; seq=""; next}} \
            {{seq=seq$0}} \
            END{{if(seq && length(seq)>=500) print header"\\n"seq}}' \
            {output.contigs} \
            > {output.filtered}
        """
