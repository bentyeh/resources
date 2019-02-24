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

# Tutorials

Harvard Chan Bioinformatics Core Training
- [In-depth NGS Data Analysis Course](https://github.com/hbctraining/In-depth-NGS-Data-Analysis-Course)
  - Differential gene expression analysis
  - Functional analysis and other RNA-seq applications
  - ChIP-seq
  - Variant calling


Griffith Lab RNA-Seq Wiki: https://github.com/griffithlab/rnaseq_tutorial/wiki

# Pipelines

[Bioconductor Workflows](https://www.bioconductor.org/packages/release/BiocViews.html#___Workflow)

# Miscellaneous

Mapping IDs
- UniProt ID mapping seems pretty incomplete, especially for UniProt <-> Ensembl Peptide/Transcript IDs
  - UniProt mapping associated with reference proteome: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640_9606.idmapping.gz
  - UniProt mapping by organism: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/HUMAN_9606_idmapping.dat.gz

Canonical transcripts and proteins for a given gene
- UniProt reference proteome
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