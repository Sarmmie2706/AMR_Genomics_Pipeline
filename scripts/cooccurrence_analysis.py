#!/usr/bin/env python3
"""
cooccurrence_analysis.py
Generates summary figures and statistics from the integrated AMR/plasmid table.

Outputs:
    gene_frequency.png          - Top 20 most detected AMR genes
    plasmid_vs_chromosome.png   - Plasmid vs chromosomal hits per sample
    gene_presence_heatmap.png   - Presence/absence heatmap across samples
    species_plasmid_burden.png  - Plasmid vs chromosomal hits by species
    cooccurrence_heatmap.png    - Gene pair co-occurrence across samples
    summary_stats.txt           - Key numbers for the Results section

Usage:
    python scripts/cooccurrence_analysis.py \
        --input results/integrated/all_samples_integrated.tsv \
        --outdir results/analysis
"""

import argparse
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns

# sample-to-species mapping from SRA metadata
SAMPLE_SPECIES = {
    "SRR19221567": "C. pasteurii",
    "SRR19221568": "E. coli",
    "SRR19221569": "K. pneumoniae",
    "SRR19221570": "K. pneumoniae",
    "SRR19221571": "E. coli",
    "SRR19221572": "E. coli",
    "SRR19221573": "K. pneumoniae",
    "SRR19221574": "K. pneumoniae",
    "SRR19221575": "E. hormaechei",
    "SRR19221576": "C. pasteurii",
    "SRR19221577": "K. pneumoniae",
    "SRR19221578": "C. freundii",
    "SRR19221579": "C. freundii",
    "SRR19221580": "C. freundii",
    "SRR19221581": "K. pneumoniae",
    "SRR19221582": "E. cloacae complex",
    "SRR19221583": "C. pasteurii",
    "SRR19221584": "E. kobei",
    "SRR19221585": "K. pneumoniae",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--outdir", required=True)
    args = ap.parse_args()

    df = pd.read_csv(args.input, sep="\t")

    # add species column from the mapping
    df["species"] = df["sample"].map(SAMPLE_SPECIES)

    # 1. GENE FREQUENCY — TOP 20 GENES BY NUMBER OF HITS
    gene_counts = df["gene"].value_counts().head(20)
    fig, ax = plt.subplots(figsize=(8, 7))
    gene_counts.sort_values().plot(kind="barh", color="steelblue", ax=ax)
    ax.set_xlabel("Number of hits across all samples")
    ax.set_title("Top 20 most frequently detected AMR genes")
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True))
    plt.tight_layout()
    plt.savefig(f"{args.outdir}/gene_frequency.png", dpi=300)
    plt.close()

    # 2. PLASMID VS CHROMOSOME — STACKED BAR PER SAMPLE
    loc_counts = (
        df.groupby(["sample", "molecule_type"])
        .size()
        .unstack(fill_value=0)
    )
    fig, ax = plt.subplots(figsize=(11, 6))
    loc_counts.plot(
        kind="bar", stacked=True, ax=ax,
        color={"plasmid": "crimson", "chromosome": "steelblue"}
    )
    ax.set_ylabel("Number of AMR gene hits")
    ax.set_title("Plasmid-borne vs chromosomal AMR genes per sample")
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha="right")
    ax.legend(title="Location")
    plt.tight_layout()
    plt.savefig(f"{args.outdir}/plasmid_vs_chromosome.png", dpi=300)
    plt.close()

    # 3. HEATMAP FOR GENE PRESENCE/ABSENCE WITH TOP 25 GENES 
    top_genes = df["gene"].value_counts().head(25).index
    heat_df = df[df["gene"].isin(top_genes)]
    presence = (
        heat_df.groupby(["sample", "gene"])
        .size()
        .unstack(fill_value=0)
        .clip(upper=3)
    )
    fig, ax = plt.subplots(figsize=(13, 8))
    sns.heatmap(
        presence, cmap="Greens", cbar=True,
        linewidths=0.4, linecolor="lightgrey", ax=ax,
        cbar_kws={"label": "Number of hits (capped at 3)"}
    )
    ax.set_title("AMR gene detection frequency across samples (top 25 genes)")
    ax.set_xlabel("Gene")
    ax.set_ylabel("Sample")
    plt.tight_layout()
    plt.savefig(f"{args.outdir}/gene_detection_heatmap.png", dpi=300)
    plt.close()

    # 4. SPECIES-LEVEL PLASMID BURDEN TO CHECK WHICH SPECIES CARRY MORE MOBILE RESISTANCE
    species_loc = (
        df.groupby(["species", "molecule_type"])
        .size()
        .unstack(fill_value=0)
    )
    fig, ax = plt.subplots(figsize=(9, 6))
    species_loc.plot(
        kind="bar", stacked=True, ax=ax,
        color={"plasmid": "crimson", "chromosome": "steelblue"}
    )
    ax.set_ylabel("Number of AMR gene hits")
    ax.set_title("Plasmid-borne vs chromosomal AMR genes by species")
    ax.set_xticklabels(ax.get_xticklabels(), rotation=30, ha="right")
    ax.legend(title="Location")
    plt.tight_layout()
    plt.savefig(f"{args.outdir}/species_plasmid_burden.png", dpi=300)
    plt.close()

    # 5. GENE PAIR CO-OCCURRENCE HEATMAP TO SHOW WHICH CLINICALLY RELEVANT RESISTANCE GENES APPEAR TOGETHER
    # genes of interest for co-occurrence analysis
    cooc_genes = [
        "TEM-1", "sul1", "sul2", "qacEdelta1",
        "dfrA7", "dfrA12", "dfrA14",
        "aadA2", "tet(A)", "tet(B)",
        "QnrB11", "QnrB17", "QnrS1",
        "mphA", "oqxA", "oqxB",
        "fosA5", "APH(3'')-Ib", "APH(6)-Id",
    ]

    # build sample x gene presence matrix for these genes
    cooc_df = df[df["gene"].isin(cooc_genes)]
    sample_gene = (
        cooc_df.groupby(["sample", "gene"])
        .size()
        .unstack(fill_value=0)
        .clip(upper=1)
    )

    # compute gene-gene co-occurrence as dot product:
    # cooc[i,j] = number of samples where both gene i and gene j are present
    cooc_matrix = sample_gene.T.dot(sample_gene)

    fig, ax = plt.subplots(figsize=(10, 8))
    sns.heatmap(
        cooc_matrix, annot=True, fmt="d",
        cmap="YlOrRd", linewidths=0.5,
        linecolor="lightgrey", ax=ax,
        cbar_kws={"label": "Number of samples where both genes co-occur"}
    )
    ax.set_title("AMR gene pair co-occurrence across samples\n"
                 "(value = number of samples carrying both genes)")
    plt.tight_layout()
    plt.savefig(f"{args.outdir}/cooccurrence_heatmap.png", dpi=300)
    plt.close()

    # 6. SUMMARY STATISTICS
    total_hits = len(df)
    plasmid_hits = (df["molecule_type"] == "plasmid").sum()
    chrom_hits = (df["molecule_type"] == "chromosome").sum()
    n_samples = df["sample"].nunique()
    n_genes = df["gene"].nunique()

    with open(f"{args.outdir}/summary_stats.txt", "w") as f:
        f.write("=" * 50 + "\n")
        f.write("SUMMARY STATISTICS\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"Total unique AMR gene hits:  {total_hits}\n")
        f.write(f"Samples analysed:            {n_samples}\n")
        f.write(f"Unique genes detected:       {n_genes}\n\n")
        f.write(f"Plasmid-borne hits:  {plasmid_hits} "
                f"({plasmid_hits/total_hits*100:.1f}%)\n")
        f.write(f"Chromosomal hits:    {chrom_hits} "
                f"({chrom_hits/total_hits*100:.1f}%)\n\n")
        f.write("Mobility class breakdown (plasmid-borne genes only):\n")
        f.write(mobility_counts.to_string())
        f.write("\n\nTop 15 genes by frequency:\n")
        f.write(df["gene"].value_counts().head(15).to_string())
        f.write("\n\nPlasmid burden by species:\n")
        f.write(species_loc.to_string())

    print(
        f"Done: {total_hits} hits across {n_samples} samples, "
        f"{n_genes} unique genes\n"
        f"Plasmid-borne: {plasmid_hits} ({plasmid_hits/total_hits*100:.1f}%)\n"
        f"Chromosomal:   {chrom_hits} ({chrom_hits/total_hits*100:.1f}%)"
    )

if __name__ == "__main__":
    main()
