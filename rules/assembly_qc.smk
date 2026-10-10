# rules/assembly_qc.smk
# Assembly quality assessment with QUAST

rule quast_qc:
    input:
        contigs = "results/assembly/{sample}/contigs_filtered.fasta",
    output:
        report = "results/assembly_qc/{sample}/report.tsv",
    params:
        outdir = "results/assembly_qc/{sample}",
    log:
        "logs/quast/{sample}.log",
    threads: 2
    shell:
        """
        mkdir -p logs/quast
        quast.py {input.contigs} \
            -o {params.outdir} \
            --threads {threads} \
            --min-contig 500 \
            > {log} 2>&1
        """
