# In Silico Characterization of Prophage Regions in Escherichia coli Genomes : Exploring Their Potential Relevance to Antimicrobial Resistance

## Overview and Objectives
This project investigates predicted prophage regions in four publicly available Escherichia coli reference genomes and examines their genomic overlap with detected antimicrobial resistance (AMR)-associated sequences.

The study applies comparative genomics and bioinformatics to characterize prophage abundance, genomic length, and distribution, alongside AMR-associated sequence screening.

- Identify and compare predicted prophage regions across four *E. coli* genomes.
- Characterize prophage abundance and length distributions.
- Screen for AMR-associated sequences and assess their genomic overlap with predicted prophage regions.

## Genomes used in the study

The analysis uses four complete NCBI RefSeq genomes: K-12 MG1655 (`NC_000913.3`), CFT073 (`NC_004431.1`), O157:H7 Sakai (`NC_002695.2`), and UTI89 (`NC_007946.1`).

## Tools and Methods

- Phigaro 2.4.0: Predicted prophage regions.
- ABRicate: Screened for AMR-associated sequences using the NCBI AMR-associated database.
- ResFinder: Provided complementary AMR screening.
- R: Supported genomic coordinate overlap analysis, statistical summaries, and visualization using packages including `ggplot2`, `readxl`, and `tidyr`.

## Key Findings

Phigaro predicted 28 prophage regions spanning 1,072,327 bp across the four genomes. O157:H7 Sakai had the highest prophage count and total predicted prophage length.

ABRicate detected four AMR-associated matches, one per genome. ResFinder detected no matches under the settings used. None of the four ABRicate matches overlapped the predicted prophage regions.

These findings are specific to the selected genomes, databases, and computational methods; they do not exclude prophage-associated AMR in other genomic contexts.

## Repository Contents

The repository contains analysis scripts, prophage region data, AMR screening results, genomic overlap verification, integrated comparison tables, and generated visualizations.

## Reproducibility

The analysis uses publicly available genomic resources and bioinformatics tools. Software versions, database versions, parameters, and input files should be documented to facilitate independent reproduction.

## Limitations

Prophage regions are computational predictions and have not been experimentally validated. Genomic overlap analysis does not establish gene transfer, gene expression, or a clinical resistance phenotype.

Research areas:Comparative genomics · Bacteriophages · Prophage prediction · Antimicrobial resistance · Bioinformatics
