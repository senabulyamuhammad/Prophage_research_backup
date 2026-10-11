import csv
from pathlib import Path

project = Path.home() / "prophage_project"
results = project / "results"
combined = results / "combined"

genomes = {
    "K-12 MG1655": {
        "folder": "ecoli_K12",
        "prefix": "ecoli_K12_MG1655",
    },
    "CFT073": {
        "folder": "ecoli_CFT073",
        "prefix": "ecoli_CFT073",
    },
    "O157:H7 Sakai": {
        "folder": "ecoli_O157_Sakai",
        "prefix": "ecoli_O157_Sakai",
    },
    "UTI89": {
        "folder": "ecoli_UTI89",
        "prefix": "ecoli_UTI89",
    },
}

def read_tsv(path):
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))

summary = {
    row["genome"]: row
    for row in read_tsv(combined / "prophage_summary.tsv")
}

output_rows = []

for genome, info in genomes.items():
    folder = results / info["folder"]
    prefix = info["prefix"]

    overlap_file = folder / f"{prefix}_AMR_prophage_overlap.tsv"
    resfinder_file = combined.parent / "resfinder" / f"{prefix}_ResFinder.tsv"

    ncbi_hits = read_tsv(overlap_file)
    resfinder_hits = read_tsv(resfinder_file)

    # Ignore empty rows; count actual gene matches only.
    ncbi_hits = [r for r in ncbi_hits if r.get("GENE", "").strip()]
    resfinder_hits = [r for r in resfinder_hits if r.get("GENE", "").strip()]

    output_rows.append({
        "genome": genome,
        "prophage_count": summary[genome]["prophage_count"],
        "total_prophage_length_bp": summary[genome]["total_prophage_length_bp"],
        "NCBI_match_count": len(ncbi_hits),
        "NCBI_match_genes": ";".join(r["GENE"] for r in ncbi_hits) or "None",
        "NCBI_matches_overlapping_prophages": sum(
            r["PROPHAGE_OVERLAP"].strip().lower() == "yes"
            for r in ncbi_hits
        ),
        "ResFinder_match_count": len(resfinder_hits),
    })

output_file = combined / "amr_prophage_summary.tsv"

with output_file.open("w", newline="") as handle:
    writer = csv.DictWriter(
        handle, fieldnames=output_rows[0].keys(), delimiter="\t"
    )
    writer.writeheader()
    writer.writerows(output_rows)

print(f"Combined results saved to: {output_file}")
for row in output_rows:
    print(
        f"{row['genome']}: "
        f"{row['prophage_count']} prophage regions; "
        f"{row['NCBI_match_count']} NCBI matches; "
        f"{row['ResFinder_match_count']} ResFinder matches; "
        f"{row['NCBI_matches_overlapping_prophages']} NCBI matches overlapping prophages"
    )
