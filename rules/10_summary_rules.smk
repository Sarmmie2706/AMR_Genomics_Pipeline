# rules/10_summary_tables.smk
"""Rules producing supplementary summary tables (CDS counts, combined contig reports, integration stats) from upstream pipeline outputs."""

rule cds_summary:
    input:
        expand("results/annotation/{sample}/{sample}.txt", sample=SAMPLES)
    output:
        "results/summary_tables/cds_summary.tsv"
    script:
        "../scripts/cds_summary.py"

rule combine_contig_reports:
    input:
        expand("results/plasmid/{sample}/contig_report.txt", sample=SAMPLES)
    output:
        "results/summary_tables/combined_contig_report.tsv"
    script:
        "../scripts/combine_contig_reports.py"

rule integration_summary:
    input:
        "results/integrated/all_samples_integrated.tsv"
    output:
        "results/summary_tables/integration_summary.txt"
    script:
        "../scripts/integration_summary.py"
