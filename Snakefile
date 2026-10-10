# Snakefile
# Genomic characterization of antimicrobial resistance determinants
# in Nigerian Enterobacteriaceae WGS data (BioProject PRJNA838568)
# Uwanibe et al. 2024, Microorganisms -- Osun State, Nigeria
#
# Usage:
#   snakemake -n          dry run (check the plan without running anything)
#   snakemake --cores 4   real run

configfile: "config/config.yaml"

with open(config["samples_file"]) as f:
    SAMPLES = [line.strip() for line in f if line.strip()]

print(f"Pipeline loaded. {len(SAMPLES)} samples found.")

include: "rules/download.smk"
include: "rules/qc.smk"
include: "rules/assembly.smk"
include: "rules/assembly_qc.smk"

rule all:
    input:
        expand("data/raw/{sample}_1.fastq.gz", sample=SAMPLES),
        expand("data/raw/{sample}_2.fastq.gz", sample=SAMPLES),
	"results/qc/multiqc_report.html",
	expand("results/assembly/{sample}/contigs.fasta", sample=SAMPLES),
	expand("results/assembly_qc/{sample}/report.tsv", sample=SAMPLES),
