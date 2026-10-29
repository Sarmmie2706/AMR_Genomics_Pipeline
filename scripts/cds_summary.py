# scripts/cds_summary.py
"""Summarise Prokka CDS counts per sample into a single TSV (rule: cds_summary)."""
output_path = snakemake.output[0]

with open(output_path, "w") as out:
    out.write("sample\tCDS\n")
    for filepath in snakemake.input:
        sample = filepath.split("/")[-2]
        cds_count = None
        with open(filepath) as f:
            for line in f:
                if line.startswith("CDS"):
                    cds_count = line.strip().split()[-1]
                    break
        out.write(f"{sample}\t{cds_count}\n")
