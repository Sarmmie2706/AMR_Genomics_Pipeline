# rules/09_cooccurrence.smk
# Co-occurrence analysis and visualisation of AMR genes and plasmid mobility
# across all 19 samples, using the integrated master table.

rule cooccurrence_analysis:
    input:
        "results/integrated/all_samples_integrated.tsv",
    output:
        "results/analysis/gene_frequency.png",
        "results/analysis/plasmid_vs_chromosome.png",
        "results/analysis/gene_detection_heatmap.png",
        "results/analysis/species_plasmid_burden.png",
        "results/analysis/cooccurrence_heatmap.png",
        "results/analysis/summary_stats.txt",
    log:
        "logs/analysis/cooccurrence.log",
    shell:
        """
        mkdir -p results/analysis logs/analysis
        python scripts/cooccurrence_analysis.py \
            --input {input} \
            --outdir results/analysis \
            2> {log}
        """
