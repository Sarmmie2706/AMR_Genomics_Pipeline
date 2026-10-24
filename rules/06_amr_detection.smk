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

# To view AMR hits for one sample against one database:
# cat results/amr/<SAMPLE>/<SAMPLE>_card.tsv
# cat results/amr/<SAMPLE>/<SAMPLE>_resfinder.tsv
# cat results/amr/<SAMPLE>/<SAMPLE>_ncbi.tsv
#
# To count genes found per sample per database:
# for sample in $(cat config/accessions.txt); do
#     count=$(tail -n +2 results/amr/${sample}/${sample}_card.tsv | wc -l)
#     echo "${sample}: ${count} CARD hits"
# done
#
# To view the cross-sample presence/absence summary:
# cat results/amr/summary_card.tsv
# cat results/amr/summary_resfinder.tsv
# cat results/amr/summary_ncbi.tsv
#
# To find which samples carry a specific gene (e.g. TEM-1):
# grep "TEM-1" results/amr/*/\*_card.tsv
#
# To see only plasmid-borne hits after integration:
# grep "plasmid" results/integrated/per_sample/<SAMPLE>_integrated.tsv
