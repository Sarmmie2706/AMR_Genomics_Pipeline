# scripts/combine_contig_reports.py
"""Combine per-sample MOB-suite contig_report.txt files into one TSV with a sample column (rule: combine_contig_reports)."""

import pandas as pd
import os

frames = []
for filepath in snakemake.input:
    sample = os.path.basename(os.path.dirname(filepath))
    df = pd.read_csv(filepath, sep="\t")
    df["sample"] = sample
    frames.append(df)

combined = pd.concat(frames, ignore_index=True)
combined.to_csv(snakemake.output[0], sep="\t", index=False)
