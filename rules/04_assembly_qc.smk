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

# To view assembly QC stats across all samples in the terminal:
# echo -e "Sample\tContigs\tTotal_length\tN50\tLargest_contig" && \
# for sample in $(cat config/accessions.txt); do
#     report="results/assembly_qc/${sample}/report.tsv"
#     contigs=$(grep "^# contigs " "$report" | head -1 | cut -f2)
#     total=$(grep "^Total length " "$report" | head -1 | cut -f2)
#     n50=$(grep "^N50" "$report" | cut -f2)
#     largest=$(grep "^Largest contig" "$report" | cut -f2)
#     echo -e "${sample}\t${contigs}\t${total}\t${n50}\t${largest}"
# done
