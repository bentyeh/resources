# Overview

| Format    | Name                       | Binary/compressed analog | Metadata           | Source           | References                                                                           | 
|-----------|----------------------------|--------------------------|--------------------|------------------|--------------------------------------------------------------------------------------| 
| SAM       | Sequence Alignment Mapping | BAM                      | @                  | bwa, bowtie2     | https://samtools.github.io/hts-specs/SAMv1.pdf                                       | 
| VCF       | Variant Call Format        | gVCF, BCF, gBCF          | #, ##              | bcftools         | https://samtools.github.io/hts-specs/VCFv4.3.pdf, http://www.htslib.org/doc/vcf.html | 
| BED       | Browser Extensible Data    | n/a                      | track, browser     |                  | https://genome.ucsc.edu/FAQ/FAQformat.html                                           | 
| GFF / GTF | General Feature Format     | n/a                      | track (unofficial) | GENCODE          | https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md          | 
| GVF       | Genome Variation Format    | n/a                      | ##                 |                  | https://github.com/The-Sequence-Ontology/Specifications/blob/master/gvf.md           | 
| Pileup    | Pileup                     | n/a                      | n/a                | samtools mpileup | http://samtools.sourceforge.net/pileup.shtml                                         | 

| Format  | Name               | Binary/compressed analog    | Source                  | Destination                                                            | References                           | 
|---------|--------------------|-----------------------------|-------------------------|------------------------------------------------------------------------|--------------------------------------| 
| fai     | FASTA Index        | n/a                         | samtools faidx <FASTA>  | samtools, bcftools                                                     | http://www.htslib.org/doc/faidx.html | 
| bai     | BAI index          | n/a                         | samtools index -b <BAM> | samtools (view RNAME[:STARTPOS[-ENDPOS]] \| idxstats \| mpileup -r), IGV |                                      | 
| csi     | CSI index          | n/a                         | samtools index -c <BAM> |                                                                        |                                      | 
| bowtie2 | FM Index - bowtie2 | .bt2                        | bowtie2                 |                                                                        |                                      | 
| bwa     | FM Index - bwa     | .amb, .ann, .bwt, .pac, .sa | bwa                     |                                                                        |                                      | 

# SAM

## Definitions

A **template** is a physical DNA molecule put on the sequencer. Multiple **reads** generated from one or more sequencing primers may come from the same template.

**singleton**
- [[samtools]](http://www.htslib.org/doc/samtools.html): a paired read whose mate is unmapped
  - FLAGs 0x40 and 0x80 indicate which of the reads in the pair was sequenced first/last
- [[in general]](https://stackoverflow.com/questions/30782192/in-bioinformatics-what-is-a-singleton): a read that did not assemble into a contig or map to a reference; a contig of 1 read

## FLAGs and read/alignment types

| Nonlinear class  | Alignment      | Assignment                   | FLAG         | CIGAR            | Alignment tags | Shared fields             | 
|------------------|----------------|------------------------------|--------------|------------------|----------------|---------------------------| 
| chimeric         | representative | arbitrary                    | 0            | soft-clipped (S) | SA             | QNAME                     | 
| chimeric         | supplementary  | arbitrary                    | 2048 (0x800) | hard-clipped (H) | SA             | QNAME                     | 
| multiple mapping | primary        | typically the best alignment | 0            |                  | HI, NH         | QNAME, FLAG 0x40 and 0x80 | 
| multiple mapping | secondary      | typically worse alignments   | 256 (0x100)  |                  | HI, NH         | QNAME, FLAG 0x40 and 0x80 | 


