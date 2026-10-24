# rules/08_integration.smk
# Integration of ABRicate AMR hits with MOB-suite plasmid classifications
# Step 1: per-sample integration (integrate_results.py)
# Step 2: combine all 19 samples + deduplicate (combine_tables.py)

rule integrate_sample:
    input:
        amr = expand(
            "results/amr/{{sample}}/{{sample}}_{db}.tsv",
            db=["card", "resfinder", "ncbi"],
        ),
        mob = "results/plasmid/{sample}/contig_report.txt",
    output:
        tsv = "results/integrated/per_sample/{sample}_integrated.tsv",
    log:
        "logs/integration/{sample}.log",
    shell:
        """
        mkdir -p results/integrated/per_sample logs/integration
        python scripts/integrate_results.py \
            --sample {wildcards.sample} \
            --amr-files {input.amr} \
            --mob-report {input.mob} \
            --output {output.tsv} \
            2> {log}
        """

rule combine_integrated:
    input:
        expand(
            "results/integrated/per_sample/{sample}_integrated.tsv",
            sample=SAMPLES,
        ),
    output:
        "results/integrated/all_samples_integrated.tsv",
    log:
        "logs/integration/combine.log",
    shell:
        """
        python scripts/combine_tables.py \
            --inputs {input} \
            --output {output} \
            2> {log}
        """

# To inspect the integrated result for one sample:
# head -5 results/integrated/per_sample/<SAMPLE>_integrated.tsv
# grep "plasmid" results/integrated/per_sample/<SAMPLE>_integrated.tsv | cut -f1,3,4,5,8,10,12,14
#
# To check the master combined table:
# wc -l results/integrated/all_samples_integrated.tsv
# head -1 results/integrated/all_samples_integrated.tsv | tr '\t' '\n' | nl
# grep "plasmid" results/integrated/all_samples_integrated.tsv | wc -l
