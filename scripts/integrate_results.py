#!/usr/bin/env python3
"""
integrate_results.py
Joins ABRicate AMR hits with MOB-suite contig classifications for one sample.

Usage:
    python scripts/integrate_results.py \
        --sample <SAMPLE_ACCESSION> \
        --amr-files results/amr/<SAMPLE>/<SAMPLE>_card.tsv \
                    results/amr/<SAMPLE>/<SAMPLE>_resfinder.tsv \
                    results/amr/<SAMPLE>/<SAMPLE>_ncbi.tsv \
        --mob-report results/plasmid/<SAMPLE>/contig_report.txt \
        --output results/integrated/per_sample/<SAMPLE>_integrated.tsv
"""

import argparse
import pandas as pd
import sys

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sample", required=True)
    ap.add_argument("--amr-files", nargs="+", required=True)
    ap.add_argument("--mob-report", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    # load ABRicate files (one for each database) and stack them on top of each other
    frames = []
    for f in args.amr_files:
        df = pd.read_csv(f, sep="\t")
        df.columns = [c.lstrip("#") for c in df.columns]
        frames.append(df)
    amr = pd.concat(frames, ignore_index=True)

    # load MOB-suite contig report
    mob = pd.read_csv(args.mob_report, sep="\t")

    # rename columns to be used in later analysis and also so both tables share the name "contig" for joining in later analysis
    amr = amr.rename(columns={
        "FILE": "file",
        "SEQUENCE": "contig",
        "GENE": "gene",
        "DATABASE": "database",
        "%IDENTITY": "pct_identity",
        "%COVERAGE": "pct_coverage",
        "RESISTANCE": "resistance_class",
    })
    mob = mob.rename(columns={
        "contig_id": "contig",
        "rep_type(s)": "rep_type",
        "relaxase_type(s)": "relaxase_type",
    })

    # keep only the required columns from each table
    amr = amr[["file","contig","gene","database",
                "pct_identity","pct_coverage","resistance_class"]]
    mob = mob[["contig","molecule_type","primary_cluster_id",
               "rep_type","relaxase_type","mpf_type","predicted_mobility"]]

    # join on contig ID 
    merged = amr.merge(mob, on="contig", how="left")

    # add sample column at the front and save to tsv
    merged.insert(0, "sample", args.sample)

    merged.to_csv(args.output, sep="\t", index=False)

    # print a quick summary
    plasmid = (merged["molecule_type"] == "plasmid").sum()
    chrom = (merged["molecule_type"] == "chromosome").sum()
    print(f"{args.sample}: {len(merged)} hits — "
          f"{plasmid} plasmid, {chrom} chromosomal",
          file=sys.stderr)

if __name__ == "__main__":
    main()
