# scripts/integration_summary.py
"""Generate summary counts (gene, molecule_type, predicted_mobility) from the integrated AMR/plasmid table (rule: integration_summary)."""

import pandas as pd

df = pd.read_csv(snakemake.input[0], sep="\t")

with open(snakemake.output[0], "w") as out:
    out.write(f"Total hits: {len(df)}\n")
    out.write(f"Samples represented: {df['sample'].nunique()}\n\n")

    out.write("Gene counts:\n")
    out.write(df["gene"].value_counts().to_string())
    out.write("\n\n")

    out.write("Molecule type counts:\n")
    out.write(df["molecule_type"].value_counts().to_string())
    out.write("\n\n")

    out.write("Predicted mobility counts:\n")
    out.write(df["predicted_mobility"].value_counts().to_string())
    out.write("\n")
