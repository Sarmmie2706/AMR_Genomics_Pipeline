# rules/annotation.smk
# Genome annotation with Prokka

rule prokka_annotate:
    input:
        contigs = "results/assembly/{sample}/contigs_filtered.fasta",
    output:
        gff = "results/annotation/{sample}/{sample}.gff",
        faa = "results/annotation/{sample}/{sample}.faa",
    params:
        outdir = "results/annotation/{sample}",
        prefix = "{sample}",
    log:
        "logs/prokka/{sample}.log",
    threads: 4
    shell:
        """
        mkdir -p logs/prokka
        prokka \
            --outdir {params.outdir} \
            --prefix {params.prefix} \
            --cpus {threads} \
            --force \
            --kingdom Bacteria \
            {input.contigs} \
            > {log} 2>&1
        """
