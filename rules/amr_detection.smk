# rules/amr_detection.smk
# AMR gene detection using ABRicate

rule abricate_screen:
    input:
        contigs = "results/assembly/{sample}/contigs_filtered.fasta",
    output:
        tsv = "results/amr/{sample}/{sample}_{db}.tsv",
    log:
        "logs/abricate/{sample}_{db}.log",
    threads: 2
    shell:
        """
        mkdir -p results/amr/{wildcards.sample} logs/abricate
        abricate \
            --db {wildcards.db} \
            --threads {threads} \
            --minid 80 \
            --mincov 80 \
            {input.contigs} \
            > {output.tsv} \
            2> {log}
        """

rule abricate_summary:
    input:
        expand(
            "results/amr/{sample}/{sample}_{{db}}.tsv",
            sample=SAMPLES,
        ),
    output:
        "results/amr/summary_{db}.tsv",
    log:
        "logs/abricate/summary_{db}.log",
    shell:
        """
        abricate --summary {input} > {output} 2> {log}
        """
