# rules/qc.smk
# Quality control and trimming of raw paired-end reads.
# fastp: trim adapters and low-quality bases, generate QC report
# FastQC: visual QC report on trimmed reads
# MultiQC: aggregate all 19 FastQC reports into one dashboard

rule fastp_trim:
    input:
        r1 = "data/raw/{sample}_1.fastq.gz",
        r2 = "data/raw/{sample}_2.fastq.gz",
    output:
        r1 = "data/trimmed/{sample}_1.trim.fastq.gz",
        r2 = "data/trimmed/{sample}_2.trim.fastq.gz",
        json = "results/qc/fastp/{sample}.json",
        html = "results/qc/fastp/{sample}.html",
    log:
        "logs/fastp/{sample}.log",
    threads: 4
    shell:
        """
        mkdir -p data/trimmed results/qc/fastp logs/fastp
        fastp \
            -i {input.r1} -I {input.r2} \
            -o {output.r1} -O {output.r2} \
            --qualified_quality_phred 20 \
            --length_required 50 \
            --thread {threads} \
            --json {output.json} \
            --html {output.html} \
            2> {log}
        """

rule fastqc_trimmed:
    input:
        r1 = "data/trimmed/{sample}_1.trim.fastq.gz",
        r2 = "data/trimmed/{sample}_2.trim.fastq.gz",
    output:
        r1_html = "results/qc/fastqc/{sample}_1.trim_fastqc.html",
        r2_html = "results/qc/fastqc/{sample}_2.trim_fastqc.html",
    log:
        "logs/fastqc/{sample}.log",
    threads: 2
    shell:
        """
        mkdir -p results/qc/fastqc logs/fastqc
        fastqc {input.r1} {input.r2} \
            -o results/qc/fastqc \
            -t {threads} \
            2> {log}
        """

rule multiqc:
    input:
        expand("results/qc/fastqc/{sample}_1.trim_fastqc.html", sample=SAMPLES),
        expand("results/qc/fastqc/{sample}_2.trim_fastqc.html", sample=SAMPLES),
    output:
        "results/qc/multiqc_report.html",
    log:
        "logs/multiqc.log",
    shell:
        """
        mkdir -p logs
        multiqc results/qc/fastqc \
            -o results/qc \
            -n multiqc_report.html \
            2> {log}
        """
