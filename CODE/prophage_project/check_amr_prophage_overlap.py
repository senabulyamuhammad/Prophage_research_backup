
import csv
import sys
from pathlib import Path

if len(sys.argv) != 4:
    print(
        "Usage: python check_amr_prophage_overlap.py "
        "<prophage.tsv> <amr.tsv> <output.tsv>"
    )
    sys.exit(1)

prophage_file = Path(sys.argv[1])
amr_file = Path(sys.argv[2])
output_file = Path(sys.argv[3])

# Read predicted prophage regions
with prophage_file.open(newline="") as f:
    prophages = list(csv.DictReader(f, delimiter="\t"))

# Read AMR matches
with amr_file.open(newline="") as f:
    amr_hits = [
        row for row in csv.DictReader(f, delimiter="\t")
        if row.get("GENE")
    ]

columns = [
    "GENE", "SEQUENCE", "START", "END",
    "%IDENTITY", "%COVERAGE",
    "OVERLAPPING_PROPHAGES", "PROPHAGE_OVERLAP"
]

with output_file.open("w", newline="") as f:
    writer = csv.DictWriter(
        f, fieldnames=columns, delimiter="\t"
    )
    writer.writeheader()

    for hit in amr_hits:
        overlaps = []
        hit_start = int(hit["START"])
        hit_end = int(hit["END"])

        for prophage in prophages:
            if hit["SEQUENCE"] != prophage["scaffold"]:
                continue

            p_start = int(prophage["begin"])
            p_end = int(prophage["end"])

            if max(hit_start, p_start) <= min(hit_end, p_end):
                overlaps.append(prophage["id"])

        writer.writerow({
            "GENE": hit["GENE"],
            "SEQUENCE": hit["SEQUENCE"],
            "START": hit["START"],
            "END": hit["END"],
            "%IDENTITY": hit["%IDENTITY"],
            "%COVERAGE": hit["%COVERAGE"],
            "OVERLAPPING_PROPHAGES": ";".join(overlaps) or "None",
            "PROPHAGE_OVERLAP": "Yes" if overlaps else "No"
        })

print(f"AMR matches analysed: {len(amr_hits)}")
print(f"Predicted prophage regions: {len(prophages)}")
print(f"Results saved to: {output_file}")
