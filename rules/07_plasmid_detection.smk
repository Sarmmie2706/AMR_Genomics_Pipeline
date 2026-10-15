# rules/plasmid_detection.smk
# Plasmid reconstruction and typing with MOB-suite

rule mob_recon:
    input:
        contigs = "results/assembly/{sample}/contigs_filtered.fasta",
    output:
        contig_report = "results/plasmid/{sample}/contig_report.txt",
    params:
        outdir = "results/plasmid/{sample}",
    log:
        "logs/mob_recon/{sample}.log",
    threads: 4
    shell:
        """
        mkdir -p logs/mob_recon
        mob_recon \
            --infile {input.contigs} \
            --outdir {params.outdir} \
            --num_threads {threads} \
            --force \
            > {log} 2>&1
        """
