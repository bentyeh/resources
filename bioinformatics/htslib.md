# htslib

http://www.htslib.org/

## Definitions

Genotype: #1/#2/.../#n for an *n*-allelic site
- Human genome is diploid --> all sites, except for X,Y chromosomes are biallelic: #1/#2
- Values of #: 0 = REF allele, 1 = 1st ALT allele, 2 = 2nd ALT allele, ...
  - REF and ALT refer to the 4th and 5th fields (columns) in a VCF file
- "/" = unphased genotype; "|" = phased genotype

Genotype likelihoods
- 2 scales: log10-likelihood ("GL" field), or phred ("PL" field)
- Likelihoods specified for each possible genotype
  - Example genotypes
    - Biallelic, REF = A, ALT = B: A/A, A/B, B/B  --> genotype likelihood = #,#,#
    - Triallelic, REF = A, ALT = B,C: A/A, A/B, B/B, A/C, B/C, C/C --> genotype likelihood = #,#,#,#,#,#
  - See section **1.6.2 Genotype fields** > "GL" field in [VCFv4.3 specs](https://samtools.github.io/hts-specs/VCFv4.3.pdf#subsubsection.1.6.2) for ordering of genotypes

## samtools

http://www.htslib.org/doc/samtools.html

### Individual tools

#### `mpileup [options] in1.bam [in2.bam [...]]`

`-f, --fasta-ref FILE`: FILE is a normal FASTA file (not an indexed .fai file). If there is not already an indexed .fai file in the same directory as FILE (e.g. from `samtools faidx FILE`), `mpileup` will create a .fai index file.\
`-r, --region REG`: REG is given as comma-separated `RNAME[:STARTPOS[-ENDPOS]]`. Requires that a BAM index (`.bai` file) exists in the directory of the BAM file.

### FAQ

**Specifying output file**\
Only output to `stdout`: flagstat, idxstats, stats\
Specify output with `-o`: view, mpileup

**Index files**

Summary
- Tools that require a FASTA file and its `.fai` index will create the FASTA index first (in the same directory as the FASTA file) if it does not exist
- Tools that require a BAM file and its `.bai` index will require that the BAM index exist in the same directory as the BAM file
- Use `samtools faidx <non-indexed FASTA file>` to create .fai FASTA index file in the same directory as the FASTA file
- Use `samtools index -b <BAM file> <BAM index file name>` to create .bai BAM index file

Tools that require .bai BAM indexes:
- idxstats
- mpileup: if `-r, --region REG` is specified

Tools that require .fai FASTA indexes:
- mpileup: if `-f, --fasta-ref FILE` is specified

Indexes

**idxstats v. flagstat v. stats**
idxstats: reference sequence name, sequence length, # mapped reads and # unmapped reads
flagstat: N + M for each of the 12 FLAG bits, where N / M are the numbers of QC-passed/-failed reads with the FLAG set
stats: very similar information to that of flagstat, but in a format to be plotted by plot-bamstats

**samtools v. bcftools mpileup**
Function: almost identical. bcftools only outputs VCF/BCF files (by default, uncompressed VCF), whereas samtools can output pileup files (default)
Arguments: very similar (see `diff` of their help outputs)
Indexes: same requirements; both will generate FASTA index if it does not already exist

## bcftools

Stable version documentation: http://www.htslib.org/doc/bcftools.html\
Development version documentation (also includes how-to guides): https://samtools.github.io/bcftools/howtos/index.html

