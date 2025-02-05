- [How-Tos](#how-tos)
  - [Convert between chromosome names](#convert-between-chromosome-names)
  - [Which genome assembly to use for alignment](#which-genome-assembly-to-use-for-alignment)
  - [Choosing blacklist regions](#choosing-blacklist-regions)
- [Genome annotations](#genome-annotations)
- [UCSC](#ucsc)
- [NCI Genomic Data Commons](#nci-genomic-data-commons)
  - [Searching and filtering data](#searching-and-filtering-data)
  - [TCGA Barcode](#tcga-barcode)
- [NCBI Entrez and E-Utilities](#ncbi-entrez-and-e-utilities)
- [NCBI Sequencing Read Archive (SRA)](#ncbi-sequencing-read-archive-sra)
  - [SRA Toolkit](#sra-toolkit)

# How-Tos

## Convert between chromosome names

Conversion tables
- NCBI genome assembly reports: assembly name <> GenBank accession <> RefSeq accession <> UCSC
  - "assembly name" is the my term for the `Sequence-Name` column in the assembly reports; these names appear in the FASTA comment of NCBI Nucleotide entries and are also used by Ensembl for alternate loci, novel patches, and fix patches (see below)
  - Example (human GRCh38): https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_assembly_report.txt
  - Example (mouse GRCm39): https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.27_GRCm39/GCF_000001635.27_GRCm39_assembly_report.txt
- UCSC chromAlias: Ensembl <> RefSeq accesion <> UCSC (and possibly more)
  - This is present in 2 formats:
    - <a name="chromAlias.txt.gz"></a>`<genome path>/database/chromAlias.txt.gz`: a long-form table, with each row representing a single conversion between a UCSC-style name and another style name
    - <a name="genome.chromAlias.txt"></a>`<genome path>/bigZips/<genome>.chromAlias.txt`: a wide-form table, with each row representing a single chromosome and columns giving all the different names for that chromosome

Format for mouse and human genomes
- NCBI GenBank: accessions
  - Human: chromosomes 1-22, X, and Y = CM000[663-686].[version]
  - Mouse: chromosomes 1-19, X, and Y = CM00[0994-1014].[version]
  - Accessions for mitochondrial chromosomes and non-reference chromosomes/scaffolds (alternate loci, unlocalized scaffolds, unplaced scaffolds, fix patches, and novel patches) do not follow a linear ordering.
- NCBI RefSeq: accessions
  - Human: chromosomes 1-22, X, and Y = NC_00000[1-24].[version]
  - Mouse: chromosomes 1-19, X, and Y = NC_0000[67-87].[version]
  - Accessions for mitochondrial chromosomes and non-reference chromosomes/scaffolds do not follow a linear ordering.
- Ensembl
  - Reference chromsomes: 1-22 (human) or 1-19 (mouse) + X + Y+ MT
  - Alternate loci, novel patches, fix patches: assembly name
  - Unlocalized scaffolds and unplaced scaffolds: GenBank accession
- [UCSC](#UCSC)
  - reference chromosomes: `chr[#|X|Y|M]`
  - unlocalized scaffolds, alternate loci scaffolds, fix loci scaffolds: `chr[#|X|Y|M]_[GenBank accession]v[GenBank version]_[random|alt|fix]`
  - unplaced scaffolds: `chrUn_[GenBank accession]v[GenBank version]`
- (human and mouse only) GENCODE
  - reference chromosomes: UCSC-style `chr[#|X|Y|M]`
  - non-reference chromosomes/scaffolds: GenBank accession.version

GRCh38.p14 notes (see also [Google Colab notebook](https://colab.research.google.com/drive/12ioyAoyZIrIFSPPE4TiclMM-1unUquFO))
- GenBank assembly accessions start with "GCA", while RefSeq assembly accessions start with "GCF".
- History: GRCh38 initial release in 2013 (GCA_000001405.15, GCF_000001405.26) contained 455 sequences (25 reference chromosomes + 127 unplaced scaffolds + 42 unlocalized scaffolds + 261 alternate loci). By Patch 14 (GCF_000001405.40, GCA_000001405.29), 4 GenBank accessions (described below) were dropped from the RefSeq assembly, while 164 fix patches and 90 novel patches have been added, for a total of 709 GenBank accessions and 705 RefSeq accessions.
  - `KI270752.1` (unplaced scaffold): dropped in patch 13 from the RefSeq assembly "because it is hamster sequence derived from the human-hamster CHO cell line" [[UCSC hg38 bigZip](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/)]
    - This sequence is still kept in the NCBI GenBank assembly. "Removal of this sequence from the GenBank assembly can only be done at the time of a new major assembly release." [[GRC Issue HG-2587](https://www.ncbi.nlm.nih.gov/grc/human/issues/HG-2587)]
  - `KI270825.1` (alternate locus), `KI270721.1` (unlocalized scaffold), `KI270734.1` (unlocalized scaffold): "contamination or obsolete" sequences dropped in patch 14 from the RefSeq assembly [[UCSC hg38 bigZip](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/)]
- Comparison with other assemblies to NCBI GenBank
  - NCBI RefSeq: excludes the 4 sequences above
  - Ensembl release 113: contains the 4 sequences above but excludes 3 fix patches `MU273354.1`, `KN538374.1`, and `MU273386.1`
  - UCSC: excludes the 4 sequences above, but contains 2 extra sequences `KQ759759.1` and `KQ759762.2`
    - `KQ759759` and `KQ759762` (fix patches) were updated from version 1 to version 2 in patch 14
    - "Because of the difficulty of removing the old chroms chr11_KQ759759v1_fix and chr22_KQ759762v1_fix from all of the database tables and bigData files, custom tracks, and hubs, we are not dropping them from the UCSC hg38 patch 14 .2bit and chromInfo. However, we have dropped them from chromAlias to accord with the Genbank and Refseq official releases for patch14." [[UCSC hg38 bigZip](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/)]
  - GENCODE: many non-reference sequences have no annotations

## Which genome assembly to use for alignment

References
- https://lh3.github.io/2017/11/13/which-human-reference-genome-to-use
- https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/README_analysis_sets.txt
- https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/

General guidelines
- Unless the aligner is "ALT-aware" and can appropriately use alternate loci sequences, do not include the alternate loci sequences in alignment indices.
- Include the unplaced and unlocalized scaffolds
  - This will prevent false alignment of reads from those genomic regions to the reference chromosomes.
- Hard-mask duplicate regions
  - Example (human genome): the two PAR regions on chromosome Y, and duplicate copies of centromeric arrays and WGS on chromosomes 5, 14, 19, 21 & 22
- An Epstein-Barr virus (EBV) sequence is often included "as a sink for alignment of reads that are often present in sequencing samples."

FASTA sequences and indices following these guidelines are termed "analysis sets":
- GRCh38.p14: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/
- GRCm39: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.27_GRCm39/seqs_for_alignment_pipelines/
- GRCm38 (mm10): use the initial assembly release sequences, which contains no alternate loci [[UCSC mm10 bigZips](https://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/)]
- T2T CHM13: ??
  - The [NCBI FTP folder for the T2T CHM13 genome](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/) does not contain an analysis set.
  - Bowtie 2 (see the sidebar on the [manual webpage](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml)) provides an index, but it is not masked. Consequently, would reads originating from repetitive/duplicate regions simply fail to align?

## Choosing blacklist regions

Referencess
- Papers
  - Amemiya HM, Kundaje A, Boyle AP. The ENCODE Blacklist: Identification of Problematic Regions of the Genome. *Sci Rep*. 2019;9(1):9354. Published 2019 Jun 27. doi:[10.1038/s41598-019-45839-z](https://doi.org/10.1038/s41598-019-45839-z)
  - Ogata JD, Mu W, Davis ES, et al. excluderanges: exclusion sets for T2T-CHM13, GRCm39, and other genome assemblies. *Bioinformatics*. 2023;39(4):btad198. doi:[10.1093/bioinformatics/btad198](https://doi.org/10.1093/bioinformatics/btad198)
- Anshul Kundaje's webpage: https://sites.google.com/site/anshulkundaje/projects/blacklists
- ENCODE Annotation File Set: https://www.encodeproject.org/annotations/ENCSR636HFF/
- Boyle lab GitHub repo: https://github.com/Boyle-Lab/Blacklist

Below, I've compiled blacklists from ENCODE and associated labs (Anshul Kundaje and the Boyle lab). For a more comprehensive and updated table of blacklists, see the [`excluderanges` package](https://dozmorovlab.github.io/excluderanges).

| Genome | Blacklist version | Links |
| ------ | ----------------- | ----- |
| hg19   | v1                | [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/Blacklist_v1/hg19-blacklist.bed.gz), [ENCODE](https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz)* |
| hg19   | v2                | [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg19-blacklist.v2.bed.gz) |
| GRCh38 | v1                | [Kundaje](http://mitra.stanford.edu/kundaje/akundaje/release/blacklists/hg38-human/hg38.blacklist.bed.gz), [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/Blacklist_v1/hg38-blacklist.bed.gz) |
| GRCh38 | v2                | [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg38-blacklist.v2.bed.gz) |
| GRCh38 | v3                | [ENCODE](https://www.encodeproject.org/files/ENCFF356LFX/@@download/ENCFF356LFX.bed.gz) |
| mm10   | v1                | [ENCODE](https://www.encodeproject.org/files/ENCFF547MET/@@download/ENCFF547MET.bed.gz), [Kundaje](http://mitra.stanford.edu/kundaje/akundaje/release/blacklists/mm10-mouse/mm10.blacklist.bed.gz), [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/Blacklist_v1/mm10-blacklist.bed.gz) |
| mm10   | v2                | [GitHub](https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz)

\* Confusingly, [Anshul Kundaje's webpage](https://sites.google.com/site/anshulkundaje/projects/blacklists) lists the hg19 annotation file [ENCFF001TDO](https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz) as both Version 1 and Version 3. The file is identical to Version 1 of the hg19 blacklist on the Boyle Lab GitHub.

# Genome annotations

Human genome
- Single representative transcripts per gene: Ensembl Canonical and RefSeq Select are supersets of MANE Select
  - MANE Select = set of Ensembl Canonical and RefSeq Select transcripts that are annotated identically in the RefSeq and the Ensembl-GENCODE gene sets and perfectly align to GRCh38
  - ([Ensembl release 112](https://ftp.ensembl.org/pub/release-112/gtf/homo_sapiens/Homo_sapiens.GRCh38.112.gtf.gz) or [GENCODE release v46](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_46/gencode.v46.primary_assembly.annotation.gtf.gz)) All transcripts tagged with "MANE_Select" are also tagged with "Ensembl Canonical"
  - ([RefSeq release GCF_000001405.40-RS_2023_10](https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/annotation_releases/GCF_000001405.40-RS_2023_10/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz)) Transcripts tagged with "MANE Select" are not additionally tagged with "RefSeq Select"
  - Versioning
    - MANE --> Ensembl and NCBI releases: see README of MANE releases on NCBI's FTP server: https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/
    - GENCODE <--> Ensembl version mapping can be found on GENCODE's website: https://www.gencodegenes.org/human/releases.html


# UCSC

Download site: https://hgdownload.soe.ucsc.edu/downloads.html

UCSC Servers (US server URLs provided; see UCSC Genome Browser's documentation for URLs for servers in Europe and elsewhere)
- HTTP server: `hgdownload.soe.ucsc.edu/`
- FTP server: `ftp://hgdownload.soe.ucsc.edu`
- MariaDB (MySQL) server: `genome-mysql.soe.ucsc.edu`

Organization of directories accessible on HTTP and FTP servers
- `goldenPath` (`https://hgdownload.soe.ucsc.edu/goldenPath/<genome>` or `ftp://hgdownload.soe.ucsc.edu/goldenPath/<genome>`): UCSC genome annotations [[UCSC Genome Browser User Guide](https://genome.ucsc.edu/goldenPath/help/hgTracksHelp.html#Download)]
  - Files in this directory are largely descriptive (showing where things are along the genome) rather than numeric.
    - Exceptions: conservation scores (under the `phyloP[#]way` and `phastCons[#]way` directories)
  - bigZips/: genome sequence, selected annotation files and updates
    > "Files in this directory reflect the initial... release of the genome, the most current versions are in the "latest/" subdirectory"
    - RepeatMasker-masked genome FASTA files
    - \<genome\>.chrom.sizes
    - [\<genome\>.chromAlias.txt](#genome.chromAlias.txt)
    - (Updated regularly) RefSeq mRNA multi-FASTA files
    - (Updated regularly) upstream1000/2000/5000: sequences 1000/2000/5000 bases upstream of annotated TSSs of RefSeq genes with annotated 5' UTRs.
  - chromosomes/: a FASTA file for each chromosome/scaffold from the initial genome assembly release (i.e., without any patches)
  - database/: annotation tables, where each table is represented by a `.sql` file containing the SQL commands used to create the table and a `.txt.gz` file of the table data in tab-delimited format. Schema descriptions can be found by selecting the relevant dataset and clicking the "Data format description" button in the [Table Browser](https://genome.ucsc.edu/cgi-bin/hgTables).
    - RepeatMasker tracks
      - rmsk.txt.gz: source unclear (not described in the GitHub repo)
      - rmskAlign* and rmskOut*: very similar, except that Align corresponds to the ".align" file generated by RepeatMasker that shows the alignments between the repeat and query sequence, which is missing from the ".out" file. rmskOut* appears to be the main annotation file to use.
      - rmsk\*Baseline vs. rmsk\*Current: based on the GitHub repo, appear to correspond to older vs. newer annotations
      - rmskJoined*: a "RepeatMasker Visualization track" (unclear)
    - [chromAlias.txt.gz](#chromAlias.txt.gz)
    - ... many others ...
- `gbdb` (`https://hgdownload.soe.ucsc.edu/gbdb/` or `ftp://hgdownload.soe.ucsc.edu/gbdb/`): bigBeds/bigWigs/BAMs and other binary files [[UCSC Genome Browser Blog](https://genome-blog.gi.ucsc.edu/blog/2018/07/20/accessing-the-genome-browser-programmatically-part-2-using-the-public-mysql-server-and-gbdb-system)]
  - This includes essentially all functional genomics data, such as expression (e.g., RNA-seq data from the FANTOM and GTEx projects), transcription factor binding (e.g., ChIP-seq data from ENCODE and ReMap), and chromatin accessibility (e.g., DNase HS signal from ENCODE).
  - Integration of 3rd-party data: TCGA, variant effect prediction scores (e.g., from CADD), aberrant splicing scores (e.g., from AbSplice)
  - Other numeric tracks: GC content

Provenance of files: https://github.com/ucscGenomeBrowser/kent/tree/master/src/hg/makeDb/doc
- Example: code for main Human GRCh38 annotations = https://github.com/ucscGenomeBrowser/kent/blob/master/src/hg/makeDb/doc/hg38/hg38.txt

# NCI Genomic Data Commons

Abbreviations
- NCI: National Cancer Institute
- GDC: Genomic Data Commons

Documentation: https://docs.gdc.cancer.gov/

## Searching and filtering data

Available fields: https://docs.gdc.cancer.gov/API/Users_Guide/Appendix_A_Available_Fields/
- Definitions of each field can be found by searching the last component of the field name (i.e., after the last period in the field name) in the  in the [GDC Data Dictionary](https://docs.gdc.cancer.gov/Data_Dictionary/gdcmvs/).

## TCGA Barcode

Abbreviations
- TSS: Tissue Source Site
- BCR: Biospecimen Core Resource

Format: `[project]-[TSS]-[participant]-[sample][vial]-[portion][analyte]-[plate]-[center]`

When retrieving data via the [GDC API](https://docs.gdc.cancer.gov/API/Users_Guide/Getting_Started/), the TCGA Barcode can be found (if applicable) under the `cases.samples.submitter_id`.

Reference
1. GDC Documentation: https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/
2. TCGA Code Tables: https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables
3. Wikipedia: https://en.wikipedia.org/wiki/The_Cancer_Genome_Atlas

# NCBI Entrez and E-Utilities

E-Direct command line tutorials
- [NCBI Workshop: Accessing NCBI Biology Resources Using EDirect for Command Line Novices](https://www.nlm.nih.gov/ncbi/workshops/2023-07_intro-to-edirect/workshop-details.html)
  - Jupyter Notebook: https://github.com/esallychang/CommandLine_EDirect_July2023
- [NCBI Workshop: Downloading NCBI Biological Data and Creating Custom Reports Using the Command Line](https://www.nlm.nih.gov/ncbi/workshops/2023-04_custom-reports/workshop-details.html)
  - Jupyter Notebook: https://github.com/esallychang/CommandLine_CustomData_April2023

Other references
- NCBI C++ Toolkit documentation: https://ncbi.github.io/cxx-toolkit/

# NCBI Sequencing Read Archive (SRA)

Accession prefixes (see https://www.ncbi.nlm.nih.gov/sra/docs/submitmeta/)
- STUDY: `SRP#`
- SAMPLE (`SRS#`): can be shared between STUDYs and between EXPERIMENTs.
- EXPERIMENT (`SRX#`): main publishable unit in the SRA database
  - Each EXPERIMENT represents a combination of biological replicate, library, sequencing strategy (e.g., targeted selection vs. unbiased), layout (e.g., paired end vs. single end), and instrument model.
- RUN (`SRR#`): a "RUN is simply a manifest of data file(s) that are derived from sequencing a library described by the associated EXPERIMENT."
  - "All data files listed in a RUN will be merged into a single \*.sra\* archive file."
- SUBMISSION (`SRA#`; non-public accession)

SRA data formats
- References
  - Overview: [SRA Documentation](https://www.ncbi.nlm.nih.gov/sra/docs/sra-data-formats/)
  - Storage: [SRA Archive Documentation](https://www.ncbi.nlm.nih.gov/sra/docs/sra-data-storage-model/), [SRA Data Working Group 2021 report](https://dpcpsi.nih.gov/sites/default/files/3.20PM-SRA-Data-WG-Final-Report-Ardlie-Gregurick-508.pdf), and NLM Support (via email on 2024-08-08)
- SRA Normalized Format (`*.sra`; aka extract-transform-load or ETL format): contains base calls, full base quality scores, and alignments
  - Discards original read names [[SRA Toolkit GitHub](https://github.com/ncbi/sra-tools/wiki/Read-Names)]
  - Storage: AWS (hot) via AWS Open Data Program --> free egress worldwide with anonymous identity
- SRA Lite (`*.sralite`; aka ETL-BQS for ETL format without base quality scores): contains base calls, per-read quality flag, and alignments
  - Discards original read names [[SRA Toolkit GitHub](https://github.com/ncbi/sra-tools/wiki/Read-Names)]
  - The per-read quality flag (`Read_Filter`) is either `pass` or `reject`. See [SRA Documentation](https://www.ncbi.nlm.nih.gov/sra/docs/sra-data-formats/) for how the SRA determines whether a read passes the read filter.
  - Storage
    - NCBI servers: free egress worldwide with anonymous identity
    - Cloud (AWS and GCP): hot; free egress to cloud services in the same geographical region
- Originally submitted source files
  - Storage: AWS, mostly cold storage

Accessing SRA data
- Web interface
  - [Run Browser](https://www.ncbi.nlm.nih.gov/Traces/index.html?view=run_browser): Search by SRA Run Accession (`SRA#`) to see metadata, taxonomy analysis, read sequences, and data access information about the run, as well as a tool to download FASTA/FASTQ files for runs in the same SRA Experiment.
    - The Data access tab indicates where the data is stored (NCBI, AWS, or GCP servers) and what types of egress is free.
    - The FASTA/FASTQ download web interface only allows a limited download of <5 Gb of sequence over HTTP. [[SRA Documentation](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/)]
  - [Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/): Search by SRA, BioProject, BioSample, or GEO accessions to see all associated SRA Runs. Offers an interface to download metadata or retrieve the data from cold cloud storage to a cloud bucket.
- AWS
  - Buckets available through the Registry of Open Data (`s3://sra-pub-src-1/`, `s3://sra-pub-src-2/`, and `s3://sra-pub-run-odp/`; see [NIH NCBI Sequence Read Archive (SRA) on AWS](https://registry.opendata.aws/ncbi-sra/)) contain "hot" data that is free to download anonymously. Those buckets can be directly browsed anonymously using commands like
    ```
    aws s3 ls s3://sra-pub-src-1/ --no-sign-request
    ```
    and files can be downloaded directly via HTTP.
    - Example: Consider [SRA Run DRR000110](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=DRR000110&display=data-access). The SRA Run Browser shows that the original FASTQ files are hosted in the S3 bucket `sra-pub-src-1` and available for anonymouse, free egress worldwide. One can list the raw files associated with that run via
      ```
      aws s3 ls s3://sra-pub-src-1/DRR000110/ --no-sign-request
      ```
      and download the files using a command like
      ```
      aws s3 cp s3://sra-pub-src-1/DRR000110 . --no-sign-request --recursive
      ```
      to copy the raw files `090324_30WB8AAXX_s_3_sequence.txt.tar.gz.1` and `090324_30WB8AAXX_s_4_sequence.txt.tar.gz.1` into the current working directory. Extracting those archives yields two FASTQ files `s_3_sequence.txt` and `s_4_sequence.txt`.
        - As shown in the SRA Run Browser, the raw TAR archives can also be directly downloaded from their S3 buckets via HTTP.
        - Instead of using the AWS CLI, the SRA Toolkit also supports downloading the raw data directly via the `--type` argument. See below.
  - All other buckets that are shown in the Run Browser for any SRA Run appear to either be region-specific in their free egress support or host data in cold storage.
- Downloading data from cold storage: use the "[Create a Data Delivery order](https://www.ncbi.nlm.nih.gov/Traces/cloud-delivery/)" page to retrieve the data into a user's cloud storage bucket. **This will incur cloud storage costs for the user.** The data can then be retrieved from the user cloud storage bucket, potentially incurring additional costs.
  - Follow the instructions on the "[Create a Data Delivery order](https://www.ncbi.nlm.nih.gov/Traces/cloud-delivery/)" page to adjust bucket permissions. I successfully retrieved data using the following permissions settings with a new S3 bucket:
    - Do not block public access (uncheck all "block public access" or "block all public access" boxes)
    - Copy the automatically generated bucket policy (JSON text) from the "[Create a Data Delivery order](https://www.ncbi.nlm.nih.gov/Traces/cloud-delivery/)" page to the "Bucket policy" section of the Permissions tab of the bucket.
    - Upon retrieval (which may take up to 48 hours), a metadata CSV file is deposited into the target bucket along with a folder (with the SRA Run accession as its name) containing the requested data.
  - If logged into your MyNCBI account, the "[Create a Data Delivery order](https://www.ncbi.nlm.nih.gov/Traces/cloud-delivery/)" page will show the status of recent data delivery orders from the last 30 days.
- Download data from hot storage: download using the SRA Toolkit or using cloud APIs
  - Example: [SRA Run DRR310659](https://trace.ncbi.nlm.nih.gov/Traces/index.html?view=run_browser&acc=DRR310659&display=data-access), which is availabe in SRA Normalized Format on GCP at `gs://sra-pub-run-110/DRR310659/DRR310659.1` with free egress to `gs.us-east1`. (It is also available with free egress worldwide from NCBI servers, but for the sake of this example, we restrict ourselves to downloading from GCP.)
    - To download using the SRA Toolkit specifically from the GCP bucket (as opposed to other servers):
      ```
      fasterq-dump --location gs://sra-pub-run-110/DRR310659/DRR310659.1 DRR310659
      ```
      - <span style="color:red">The `--location` argument is explained in the help of `fasterq-dump` version 3.0.0 but not the latest SRA Toolkit version 3.1.1.</span>
    - To download using the `gcloud` CLI:
      ```
      gcloud storage --billing-project=<billing-project> cp gs://sra-pub-run-110/DRR310659/DRR310659.1 .
      ```
      where `<billing-project>` is a project ID shown under the "ID" column at https://console.cloud.google.com/billing/projects. This downloads a SRA Normalized Format file that can be converted to FASTQ and other formats via the SRA Toolkit programs, such as
      ```
      fasterq-dump ./DRR310659
      ```
    - Costs: Presumably if these commands are run within a Google Cloud virtual machine ([Cloud Shell](https://cloud.google.com/shell) or [Compute Engine](https://cloud.google.com/products/compute) instance) located in a `us-east1` region, then the download is free. However, if downloading to local premises, then an egress cost may be incurred.
  - If originally submitted source files are available in hot storage, they can be downloaded directly using the SRA Toolkit by using the `--type` argument.
    - Example: The Run Browser for [SRA Run DRR000110](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=DRR000110&display=data-access) lists the original format files as type `fastq`. We already previously explored how to download the raw files via HTTP or the AWS CLI. To download using the SRA Toolkit, run
      ```
      prefetch --type fastq DRR000110
      ```
      which will create a folder DRR000110 with the 2 raw data files inside: `090324_30WB8AAXX_s_3_sequence.txt.tar.gz` and `090324_30WB8AAXX_s_4_sequence.txt.tar.gz`.

## SRA Toolkit

Documentation: https://github.com/ncbi/sra-tools/wiki
- Note (as of 2024-08-07): Because there are a lot of Wiki pages, some of them are initially hidden. Click on "Show 11 more pages..." to see all of them.

Building from source: see https://github.com/ncbi/sra-tools/issues/937#issuecomment-2129704817

```
# set where to install the sratoolkit
DIR_INSTALL="$HOME/local/sratoolkit"
# set where to download source code and create build directory
DIR_TMP="$HOME/tmp/scratch/sratoolkit_build"

cd "$DIR_TMP"
git clone https://github.com/ncbi/ncbi-vdb.git
git clone https://github.com/ncbi/sra-tools.git
mkdir build
cd build
cmake -S "$(cd ../ncbi-vdb; pwd)" -B ncbi-vdb
cmake --build ncbi-vdb
cmake -D VDB_LIBDIR="${PWD}/ncbi-vdb/lib" -D CMAKE_INSTALL_PREFIX="$DIR_INSTALL" -S "$(cd ../sra-tools; pwd)" -B sra-tools 
cmake --build sra-tools --target install

# binaries are installed to "$DIR_INSTALL/bin/
```


```
DIR_WD="$(pwd -P)"
mkdir sra_install
mkdir sra_build
mkdir sra_src
cd sra_src
git clone https://github.com/ncbi/ncbi-vdb.git
git clone https://github.com/ncbi/sra-tools.git
cd ncbi-vdb
./configure --build-prefix="$DIR_WD/sra_build" --prefix="$DIR_WD/sra_install"
make
make install
cd ../sra-tools
./configure --build-prefix="$DIR_WD/sra_build" --prefix="$DIR_WD/sra_install"
make
make install

# binaries are now available at "$DIR_WD/bin"
```

There are 2 basic ways to download data from the SRA with the SRA Toolkit:
1. Prefetch and then extract to desired data type
   - Tutorial: https://github.com/ncbi/sra-tools/wiki/08.-prefetch-and-fasterq-dump
   - For in-depth documentation for the `fasterq-dump` tool, see the page [`HowTo: fasterq dump`](https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump`).
2. On demand
   - Tutorial: https://github.com/ncbi/sra-tools/wiki/Download-On-Demand


While `prefetch` and `fasterq-dump` are the main programs, the SRA Toolkit comes with all of the following tools in the `bin` directory where it is installed. Some useful commands are indicated below.
- `abi-dump`
- `align-info`
- `cache-mgr`
- `check-corrupt`
- `fasterq-dump`
- `fastq-dump`
- `illumina-dump`
- `kcbmeta`
- `ngs-pileup`
- `prefetch`
  - Use the `--max-size` argument to download more than 20 GB of data.
- `rcexplain`
- `ref-variation`
- `sam-dump`
- `sff-dump`
- `sra-info`
- `srapath`
- `sra-pileup`
- `sra-search`
- `sra-stat`
- `sratools`
- `test-sra`
- `var-expand`
- `vdb-config`
  - The full configuration of the toolkit can be viewed by running `vdb-config`. It appears that the interactive configuration settings from running `vdb-config -i` are saved to `~/.ncbi/user-settings.mkfg`.
  - The interactive form of `vdb-config` does not expose all settings, some of which can only be set via the command line. See https://github.com/ncbi/sra-tools/wiki/06.-Connection-Timeouts.
- `vdb-decrypt`
- `vdb-dump`
  - `vdb-dump --info <accession>`: show the size (in bytes) of the accession, among other information
- `vdb-encrypt`
- `vdb-validate`
