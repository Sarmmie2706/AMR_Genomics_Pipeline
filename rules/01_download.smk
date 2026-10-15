# rules/download.smk
# Pull paired-end FASTQ reads from SRA for a given sample accession.

rule download_reads:
    output:
        r1 = "data/raw/{sample}_1.fastq.gz",
        r2 = "data/raw/{sample}_2.fastq.gz",
    log:
        "logs/download/{sample}.log",
    threads: 4
    shell:
        """
        mkdir -p data/raw logs/download
        prefetch {wildcards.sample} -O data/raw > {log} 2>&1
        fasterq-dump {wildcards.sample} \
            --split-files --threads {threads} \
	    --mem 4000MB \
            -O data/raw >> {log} 2>&1
        gzip -f data/raw/{wildcards.sample}_1.fastq
        gzip -f data/raw/{wildcards.sample}_2.fastq
        rm -rf data/raw/{wildcards.sample}
        """
