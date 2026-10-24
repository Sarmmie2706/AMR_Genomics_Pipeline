#!/usr/bin/env python3
"""
combine_tables.py
Concatenates all per-sample integrated TSV files into one master table.

Usage:
    python scripts/combine_tables.py \
        --inputs results/integrated/per_sample/*.tsv \
        --output results/integrated/all_samples_integrated.tsv
"""

import argparse
import pandas as pd
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--inputs", nargs="+", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    # load and stack all files
    frames = [pd.read_csv(f, sep="\t") for f in args.inputs]
    combined = pd.concat(frames, ignore_index=True)

    # drop placeholder rows from samples with zero hits
    combined = combined.dropna(subset=["gene"])

    # record which databases confirmed each gene per sample+contig
    combined["databases_confirmed"] = (
        combined.groupby(["sample", "contig", "gene"])["database"]
        .transform(lambda x: ";".join(sorted(x.unique())))
    )

    # keep highest-identity hit per (sample, contig, gene)
    combined = (
        combined
        .sort_values("pct_identity", ascending=False)
        .drop_duplicates(subset=["sample", "contig", "gene"])
        .drop(columns=["database"])
        .reset_index(drop=True)
    )

    combined.to_csv(args.output, sep="\t", index=False)
    print(f"Done: {len(combined)} unique AMR hits across all samples",
          file=sys.stderr)


if __name__ == "__main__":
    main()
