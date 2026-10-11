
#!/bin/bash
set -euo pipefail

PROJECT="$HOME/prophage_project"
DATA="$PROJECT/data"
RESULTS="$PROJECT/results"

echo "=================================="
echo "Prophage–AMR Research Pipeline"
echo "=================================="

source /opt/miniconda3/etc/profile.d/conda.sh

# Stage 1: Predict prophage regions
conda activate phigaro

for genome in "$DATA"/*.fasta; do
    [[ -f "$genome" ]] || continue

    name=$(basename "$genome" .fasta)

if [[ "$name" == "ecoli_K12_MG1655" ]]; then
    out="$RESULTS/ecoli_K12"
else
    out="$RESULTS/$name"
fi

    mkdir -p "$out"

    if [[ ! -s "$out/${name}.phigaro.tsv" ]]; then
        echo "Running Phigaro on $name..."

        phigaro \
          -f "$genome" \
          -o "$out" \
          -e html tsv gff \
          --not-open \
          -t 2
    else
        echo "Phigaro results already exist for $name; skipping."
    fi
done

echo "Phigaro stage complete."

# Stage 2: Screen genomes for AMR genes
conda activate amrscan

for genome in "$DATA"/*.fasta; do
    [[ -f "$genome" ]] || continue

    name=$(basename "$genome" .fasta)

    if [[ "$name" == "ecoli_K12_MG1655" ]]; then
        out="$RESULTS/ecoli_K12"
    else
        out="$RESULTS/$name"
    fi

    mkdir -p "$out"
    amr_output="$out/${name}_AMR.tsv"

    if [[ ! -s "$amr_output" ]]; then
        echo "Running ABRicate on $name..."

        abricate --db ncbi "$genome" > "$amr_output"
    else
        echo "AMR results already exist for $name; skipping."
    fi
done

echo "AMR screening stage complete."

# Stage 3: Check AMR–prophage coordinate overlap
conda activate base

for genome in "$DATA"/*.fasta; do
    [[ -f "$genome" ]] || continue

    name=$(basename "$genome" .fasta)

    if [[ "$name" == "ecoli_K12_MG1655" ]]; then
        out="$RESULTS/ecoli_K12"
    else
        out="$RESULTS/$name"
    fi

    prophage_tsv="$out/${name}.phigaro.tsv"
    amr_tsv="$out/${name}_AMR.tsv"

    if [[ "$name" == "ecoli_K12_MG1655" ]]; then
        prophage_tsv="$out/ecoli_K12_MG1655.phigaro.tsv"
    fi

        if [[ -s "$prophage_tsv" && -s "$amr_tsv" ]]; then
        echo "Checking overlap for $name..."
        overlap_output="$out/${name}_AMR_prophage_overlap.tsv"

        python "$PROJECT/check_amr_prophage_overlap.py" \
            "$prophage_tsv" "$amr_tsv" "$overlap_output"
    else
        echo "Skipping overlap for $name: required files missing."
    fi
done

echo "Overlap analysis stage complete."
