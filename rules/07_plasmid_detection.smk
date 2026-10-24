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

# To check plasmid vs chromosome contig counts per sample:
# for sample in $(cat config/accessions.txt); do
#     plasmid=$(grep -c "plasmid" results/plasmid/${sample}/contig_report.txt 2>/dev/null || echo 0)
#     chrom=$(grep -c "chromosome" results/plasmid/${sample}/contig_report.txt 2>/dev/null || echo 0)
#     echo "${sample}: ${plasmid} plasmid contigs, ${chrom} chromosomal contigs"
# done
#
# To inspect plasmid hits for one sample:
# grep "plasmid" results/plasmid/<SAMPLE>/contig_report.txt | cut -f2,5,10,12,14,18
