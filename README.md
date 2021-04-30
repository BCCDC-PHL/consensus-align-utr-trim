# consensus-align-utr-trim

A small pipeline that takes SARS-CoV-2 consensus sequences, aligns them against a reference genome while constraining
the length of the alignment to match the lenght of the reference genome (using `mafft --keeplength`). After alignment,
the 5' and 3' untranslated regions (UTRs) are trimmed.

## Usage

```
nextflow run BCCDC-PHL/consensus-align-utr-trim \
  [--ref <path_to_ref_genome>] \
  --run_dir <path_to_run_dir>
```