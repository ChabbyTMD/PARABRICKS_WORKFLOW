# Sample sheet generation user guide

Ensure all your paired-end sequence reads are present in a single directory.

List all the files in your reads directory and redirect to a new file e.g.

```bash
ls *.gz > reads
```

Confirm each sequence file, is present on a new line. Next, execute the sample sheet constructor by providing the `reads` text file as input and a desired sample sheet name as the second argument e.g.

```bash
bash build_sample_sheet.sh reads samplesheet.csv
```

Inspect the sample sheet and move the `samplesheet.csv` to the `config/` directory.
