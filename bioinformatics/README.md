# Courses

[Stanford BIOS 221: Modern Statistics for Modern Biology](http://web.stanford.edu/class/bios221/book/introduction.html)

[HarvardX Biomedical Data Science Open Online Training](https://rafalab.github.io/pages/harvardx.html)
- Textbook: [HarvardX PH525x series - Biomedical Data Science](https://genomicsclass.github.io/book/)

[JHU Data Science Lab](http://jhudatascience.org/courses.html)
- [Genomic Data Science Specialization](https://www.coursera.org/specializations/genomic-data-science)
  - [Bioconductor for Genomic Data Science](https://www.coursera.org/learn/bioconductor)
    - Notes: https://kasperdanielhansen.github.io/genbioconductor/

- [UCSD Bioinformatics Specialization](https://www.coursera.org/specializations/bioinformatics)

[UCR GEN242: Data Analysis in Genome Biology](http://girke.bioinformatics.ucr.edu/GEN242/index.html)

European Molecular Biology Laboratory
- [Conferences and Courses](https://www.embl.de/training/events/)
- [EMBL-EBI Training](https://www.ebi.ac.uk/training)

[Harvard STAT115/215 BIO/BST282: Introduction to Bioinformatics and Computational Biology](https://liulab-dfci.github.io/bioinfo-combio)

# Tutorials

Harvard Chan Bioinformatics Core Training: https://hbctraining.github.io/main/
- While most lessons are in HTML format available through links on the training website, some are only availble as markdown files on in underlying GitHub repos: https://github.com/hbctraining
- [In-depth NGS Data Analysis Course](https://github.com/hbctraining/In-depth-NGS-Data-Analysis-Course)
  - Differential gene expression analysis
  - Functional analysis and other RNA-seq applications
  - ChIP-seq
  - Variant calling

Griffith Lab RNA-Seq Wiki:
- https://github.com/griffithlab/rnaseq_tutorial/wiki
- https://rnabio.org/course/

# Pipelines

[Bioconductor Workflows](https://www.bioconductor.org/packages/release/BiocViews.html#___Workflow)

# Packages

Actively maintained, well-documented Python general bioinformatics packages
- [bioframe](https://bioframe.readthedocs.io/): in-memory interval operations built on top of pandas DataFrames
  - Developed by the Open Chromosome Collective (Open2C); NumFOCUS-affiliated
- [Biopython](https://biopython.org/)
  - Developed by the Open Bioinformatics Foundation
- [scikit-bio](https://scikit.bio/)
  - Intervals: in-memory interval tree; rudimentary support for finding overlaps
  - Developed by Zhu lab (ASU), Knight lab (UCSD), and Gutz Analytics; funded by DoE grant
- [biotite](https://www.biotite-python.org/)
  - Intervals: annotation objects; rudimentary support for finding overlaps (via slice indices)
  - Developed by Hamacher lab at Technical University of Darmstadt, Germany; website indicates sponsorship from VantAI

Actively maintained sequencing/genomics packages
- [HTSeq](https://htseq.readthedocs.io/)
- [CNVkit and scikit-genome (skgenome)](https://cnvkit.readthedocs.io/)
- [bx-python](https://bx-python.readthedocs.io/)

# Miscellaneous

Mapping IDs
- UniProt ID mapping seems pretty incomplete, especially for UniProt <-> Ensembl Peptide/Transcript IDs
  - UniProt mapping associated with reference proteome: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640_9606.idmapping.gz
  - UniProt mapping by organism: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping.dat.gz

Canonical transcripts and proteins for a given gene
- Ensembl Canonical transcript: "a single, representative transcript identified at every locus" [[Ensembl](https://www.ensembl.org/info/genome/genebuild/canonical.html)]
- RefSeq Select transcript: single representative transcript for every protein-coding gene [[RefSeq Select](https://www.ncbi.nlm.nih.gov/refseq/refseq_select)]
  - First incorporated into RefSeq release 94 in May 2019 [[RefSeq release notes](https://ftp.ncbi.nlm.nih.gov/refseq/release/release-notes/archive/RefSeq-release94.txt); [NCBI Insights Blog](https://ncbiinsights.ncbi.nlm.nih.gov/2019/05/17/refseq-release-94-with-mane-and-refseq-select-markup-protein-name-evidence-and-improved-candida-auris-assembly/)]
  - Currently available for human, mouse, rat, and prokaryotic genomes
  - Matched Annotation from NCBI and EMBL-EBI (MANE): set of human transcripts that are annotated identically in the RefSeq and the Ensembl-GENCODE gene sets and perfectly align to GRCh38; subset of the intersection of RefSeq Select and Ensembl Canonical transcripts.
- UniProt reference proteome
- Outdated
  - UCSC knownCanonical track
  - https://groups.google.com/a/soe.ucsc.edu/forum/#!msg/genome/_6asF5KciPc/bWn4g3vCFAAJ

# References

Consortia
- [ENCODE](https://www.encodeproject.org/pipelines/)
- [National Cancer Institute (NCI) Genomic Data Commons (GDC)](https://docs.gdc.cancer.gov/Data/Introduction/)

RNA-Seq
- Trapnell, Cole, et al. "Differential gene and transcript expression analysis of RNA-seq experiments with TopHat and Cufflinks." *Nature Protocols* 7.3 (2012): 562. https://10.1038/nprot.2012.016
- Yalamanchili, Hari Krishna, Ying‐Wooi Wan, and Zhandong Liu. "Data Analysis Pipeline for RNA‐seq Experiments: From Differential Expression to Cryptic Splicing." *Current Protocols in Bioinformatics* 59.1 (2017): 11-15. https://doi.org/10.1002/cpbi.33
- Conesa, Ana, et al. "A survey of best practices for RNA-seq data analysis." *Genome Biology* 17.1 (2016): 13. https://doi.org/10.1186/s13059-016-0881-8

*Nature Methods* Points of Significance: https://www.nature.com/collections/qghhqm/pointsofsignificance

Collection of notes by Virginia Commonwealth University Professor Mikhail Dozmorov: https://github.com/mdozmorov/MDnotes