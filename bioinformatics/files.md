# Overview

| Format | Binary equivalent | Header | Output from               | Program (input)    | References                                               |
|--------|-------------------|--------|---------------------------|--------------------|----------------------------------------------------------|
| SAM    | BAM               | @      | aligner (bwa, bowtie2)    | samtools           | [spec](https://samtools.github.io/hts-specs/SAMv1.pdf)   |
| VCF    | BCF               | \#\#   | variant caller (bcftools) | bcftools           | [spec](https://samtools.github.io/hts-specs/VCFv4.2.pdf) |
| pileup | n/a               |        |                           |                    |                                                          |
| fai    | n/a               | n/a    | samtools faidx            | samtools, bcftools | [spec](http://www.htslib.org/doc/faidx.html)             |


# SAM

## FLAGs and read/alignment types

Chimeric reads: abitrary decision regarding which linear alignment(s) is **representative** versus **supplementary**\
Multiply mapped reads: typically the best alignment is designated **primary**; others are labeled **secondary**\
Paired-end (mate pair) reads
- **template**: the full-length sequence as put on the sequencer (i.e., the 5' and 3' ends of the template are sequenced)
- **singleton**
  - [[samtools]](http://www.htslib.org/doc/samtools.html): a paired read whose mate is unmapped
    - FLAGs 0x40 and 0x80 indicate which of the reads in the pair was sequenced first/last
  - [[in general]](https://stackoverflow.com/questions/30782192/in-bioinformatics-what-is-a-singleton): a read that did not assemble into a contig or map to a reference; a contig of 1 read
