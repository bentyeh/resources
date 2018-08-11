## HOMER

### Usage notes
Finding motifs
- log p-values outputed by findMotifs.pl in knownResults.txt or any of the \*.motif file outputs is the *natural* log p-value
  - Source: compare p-value and log p-value of outputs

### Motif library

Overview
- Filename
  - known.motifs: known motif enrichment
    - HOMER motif library (data/knownTFs/motifs/\<mset>/\*.motif) + personal motif library (motifs/)
      - [vertebrates only] HOMER motif library = data/knownTFs/motifs/\*.motif
  - all.motifs: check against de novo motifs
    - known.motifs + updated JASPAR files (update/motifs/\*/\*.motifs) + common motifs (update/motifs/common.motifs)
- Directory
  - motifs/: custom motifs to be added to data/knownTFs/motifs by updateMotifFiles.pl
    - motifs in sudirectories motifs/\<mset> get copied over to corresponding data/knownTFs/motifs/\<mset> subdirectories and therefore get concatenated into the data/knownTFs/\<mset>/known.motifs
- Mapping from organism to \<mset> determined in data/knownTFs/organism.table.txt

| Organism | human       | mouse       | rat         | frog        | zebrafish   | fly     | worm  | yeast | arabidopsis |
| :------- | :---------- | :---------- | :---------- | :---------- | :---------- | :------ | :---- | :---- | :---------- |
| \<mset>  | vertebrates | vertebrates | vertebrates | vertebrates | vertebrates | insects | worms | yeast | plants      |


Concatenation hierarchy of motif files (all paths relative to root path of HOMER installation)
- **data/knownTFs/\<mset>/all.motifs**
  - **data/knownTFs/\<mset>/known.motifs**
    - data/knownTFs/motifs/\<mset>/\*.motif  (includes motifs copied from motifs/ folder)
  - update/motifs/common.motifs
  - update/motifs/\<mset>/\*.motifs
    - jaspar.motifs
    - other files
- **data/knownTFs/vertebrates/all.motifs**
  - **data/knownTFs/vertebrates/known.motifs**
    - data/knownTFs/motifs/\*.motif  (includes motifs copied from motifs/ folder)
  - update/motifs/common.motifs
  - update/motifs/vertebrates/\*.motifs
    - jaspar.motifs
    - vert.extra.jaspar.motifs
- **data/knownTFs/[all/]all.motifs**
  - **data/knownTFs/[all/]known.motifs**
    - data/knownTFs/motifs/\*.motif  (includes motifs copied from motifs/ folder)
    - data/knownTFs/motifs/\*/\*.motif  (includes motifs copied from motifs/ folder)
  - update/motifs/common.motifs
  - update/motifs/\*/\*.motifs

### Additional data/ files
promoter/: sequence files for motif enrichment analysis
- not included in the base installation: downloaded via `perl configureHomer.pl -install human-p`

accession/: flat files for accession number conversion
- not included in the base installation: downloaded via `perl configureHomer.pl -install human-o`

### References

How motif libraries are used: bin/findMotifs.pl > bin/HomerConfig.pm > `checkMSet()`

How motif libraries are constructed: update/updateMotifFiles.pl

