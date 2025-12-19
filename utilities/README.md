# Sample sheet generation user guide

Ensure all your paired-end sequence reads are present in a single directory.

List all the files in your reads directory and redirect to a new file e.g.

```bash
ls *.gz > reads
```

Confirm each sequence file, is present on a new line. Next, execute the sample sheet constructor by providing the `reads` text file as input and a desired sample sheet name as the second argument and leading prefix to your sample name e.g.

```bash
bash build_sample_sheet.sh reads samplesheet.csv <prefix>
```
The prefix is determined by the leading characters and an underscore followed by a sample name  e.g.

```
PREFIX_SAMPLENAME_L00{LANE-NUMBER}_R[1 OR 2]_001.fastq.gz
```

Inspect the sample sheet and move the `samplesheet.csv` to the `config/` directory.
