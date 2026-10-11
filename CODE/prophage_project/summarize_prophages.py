
import csv
from pathlib import Path

project = Path.home() / "prophage_project"
results = project / "results"

genomes = {
    "K-12 MG1655": results / "ecoli_K12" / "ecoli_K12_MG1655.phigaro.tsv",
    "CFT073": results / "ecoli_CFT073" / "ecoli_CFT073.phigaro.tsv",
    "O157:H7 Sakai": results / "ecoli_O157_Sakai" / "ecoli_O157_Sakai.phigaro.tsv",
    "UTI89": results / "ecoli_UTI89" / "ecoli_UTI89.phigaro.tsv",
}

combined = results / "combined"
combined.mkdir(parents=True, exist_ok=True)

region_rows = []
summary_rows = []

for genome_name, filepath in genomes.items():
    if not filepath.exists():
        raise FileNotFoundError(f"Missing file: {filepath}")

    with filepath.open(newline="") as file:
        reader = csv.DictReader(file, delimiter="\t")
        rows = list(reader)

    lengths = []
    transposable_count = 0

    for row in rows:
        begin = int(row["begin"])
        end = int(row["end"])
        length = abs(end - begin) + 1

        transposable = row["transposable"].strip().lower() == "true"
        transposable_count += int(transposable)
        lengths.append(length)

        region_rows.append({
            "genome": genome_name,
            "scaffold": row["scaffold"],
            "prophage_id": row["id"],
            "begin": begin,
            "end": end,
            "length_bp": length,
            "transposable": row["transposable"],
            "taxonomy": row["taxonomy"],
        })

    summary_rows.append({
        "genome": genome_name,
        "prophage_count": len(rows),
        "total_prophage_length_bp": sum(lengths),
        "mean_prophage_length_bp": round(sum(lengths) / len(lengths), 2) if lengths else 0,
        "transposable_count": transposable_count,
    })

def write_tsv(path, rows):
    if not rows:
        return

    with path.open("w", newline="") as file:
        writer = csv.DictWriter(
            file, fieldnames=rows[0].keys(), delimiter="\t"
        )
        writer.writeheader()
        writer.writerows(rows)

write_tsv(combined / "prophage_regions.tsv", region_rows)
write_tsv(combined / "prophage_summary.tsv", summary_rows)

print("Prophage summary completed.")
print(f"Regions table: {combined / 'prophage_regions.tsv'}")
print(f"Summary table: {combined / 'prophage_summary.tsv'}")
print()
print("Genome-level summary:")

for row in summary_rows:
    print(
        f"{row['genome']}: "
        f"{row['prophage_count']} regions, "
        f"{row['total_prophage_length_bp']} bp total, "
        f"{row['mean_prophage_length_bp']} bp mean length, "
        f"{row['transposable_count']} flagged as transposable"
    )

print("Prophage summary completed.")
print(f"Regions table: {combined / 'prophage_regions.tsv'}")
print(f"Summary table: {combined / 'prophage_summary.tsv'}")
print()
print("Genome-level summary:")

for row in summary_rows:
    print(
        f"{row['genome']}: "
        f"{row['prophage_count']} regions, "
        f"{row['total_prophage_length_bp']} bp total, "
        f"{row['transposable_count']} flagged as transposable"
    )

