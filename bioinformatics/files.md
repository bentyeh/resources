# Overview

| Format | Binary equivalent | Header | Output from               | Program (input)    | References                                               |
|--------|-------------------|--------|---------------------------|--------------------|----------------------------------------------------------|
| SAM    | BAM               | @      | aligner (bwa, bowtie2)    | samtools           | [spec](https://samtools.github.io/hts-specs/SAMv1.pdf)   |
| VCF    | BCF               | \#\#   | variant caller (bcftools) | bcftools           | [spec](https://samtools.github.io/hts-specs/VCFv4.2.pdf) |
| pileup | n/a               |        |                           |                    |                                                          |
| fai    | n/a               | n/a    | samtools faidx            | samtools, bcftools | [spec](http://www.htslib.org/doc/faidx.html)             |


# SAM

## FLAGs
Supplementary versus secondary alignments
- Supplementary: chimeric reads
  - "The decision regarding which linear alignment is representative is arbitrary."
- Secondary: multiple mapping
  - "Typically the alignment designated primary is the best alignment, but the decision may be arbitrary."

## Questions
1. What are singleton reads?
