# HOMER

## Usage notes <a name="usage"></a>

Finding motifs
- log p-values outputed by findMotifs.pl in knownResults.txt or any of the \*.motif file outputs is the *natural* log p-value (source: compare p-value and log p-value of outputs)
- The hypergeometric p-value is calculated based on *estimates* of the number of sequences containing the motif in the target and background sets. Estimates are calculated identically but separately for target and background sets.
  - Let $N$ be the number of total sequences (either in the target or background set). Let $k_i$ be the estimated number of sequences containing the motif (regardless of multiplicity) given the presence of $i$ matching instances (oligos) in $N$ total sequences. Then $k_i$ is computed recursively as

    \begin{gather}
    k_1 = 1 \\
    k_i = k_{i-1} + \frac{N - k_{i-1}}{N}
    \end{gather}

    This is why the "Number of Target/Background Sequences with motif" reported in homerResults/motif[#].info.html (*de novo* motifs) or knownResults.html (known motifs) are not necessarily integers and may be decimal numbers. When calcuating the hypergeometric p-value, these counts are rounded to the nearest integer.
  - Reference: [http://homer.ucsd.edu/homer/introduction/motifDetails.html](http://homer.ucsd.edu/homer/introduction/motifDetails.html)
- The "Consensus" sequence in knownResults.txt output may be different than the consensus sequence of the matched known motif in the library.
  - During ["part 2" of motif local optimization](http://homer.ucsd.edu/homer/introduction/motifDetails.html), the motifs are optimized (e.g., substituting in [IUPAC nucleotide ambiguity codes](https://en.wikipedia.org/wiki/Nucleic_acid_notation)) to achieve higher enrichment scores.

## Motif library

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

## Questions

1. What are all the threshold parameters?
   - `minlp` (default = -10): natural log p-value threshold at which to stop searching for and optimizing for additional motif seeds
     - At this point, each oligo has already been expanded into a putative ("seed") motif by constructing a motif matrix based on matched instances with at most 2 mismatches. The enrichment (hypergeometric p-value) of each seed motif is then compared against this `minlp` threshold.
     - If left at its default value of -10, HOMER (in cpp/Motif2.cpp, as `minimumSeedLogp`) automatically re-adjusts this value based on the number of target sequences.
   - `reduceThresh` (default = 0.6): similarity threshold to remove similar motifs
   - `matchThresh` (default = T10): similarity threshold to report alignment (i.e., of *de novo* motifs) with known motifs
     - Valid values
       - #: motif matrix correlation threshold
       - T\[#\]: report top # known motifs regardless of similarity
     - Reference: bin/compareMotifs.pl
   - `knownPvalueThresh` (default = 0.01): hypergeometric (or binomial) p-value cutoff for finding known motifs
     - Determines which known motifs are shown in knownResults.html and in the {outputdir}/knownResults subdirectory
     - Does not limit known motifs in knownResults.txt
       - knownResults.txt simply contains statistics (e.g., P-value, Q-value, # of Target Sequences with Motif, etc.) of matching each known motif to gene set.

2. How is the log-odds threshold value in motif files used by HOMER?
   - A given sequence is considered to match a known motif if the calculated score (below) > log-odds threshold
     $$\text{score} = \sum_{nt} \log \left( \frac{\text{observed}}{\text{expected}} \right) = \sum_{nt} \log \left( \frac{\text{probability of nt at corresponding position in motif matrix}}{0.25} \right) = \log \left( \frac{\Pi_{nt} P(\text{nt})}{0.25^{\text{length}(\text{motif})}} \right) $$
       - $\log$ of multiplying the probability of seeing each nucleotide (nt) at each position in the motif
       - HOMER fixes the log-odds expectation at 0.25 for each nucleotide
   - Used to find instances of motifs (e.g. of enriched known or *de novo* motifs)
   - Reference: [http://homer.ucsd.edu/homer/motif/creatingCustomMotifs.html](http://homer.ucsd.edu/homer/motif/creatingCustomMotifs.html)

3. How are the log-odds threshold values calculated for found enriched motifs?
   - Known motifs: log-odds threshold from the library motif files are preserved.
   - *de novo* motifs: the threshold that results in the most significant enrichment
     - Reference: [http://homer.ucsd.edu/homer/introduction/motifDetails.html](http://homer.ucsd.edu/homer/introduction/motifDetails.html)

4. How *exactly* are the hypergeometric p-values calculated?
   - I understand that the counts of sequences with motifs are estimated (see [Usage notes](#usage)). However, the p-values I calculate using those counts is still different than what HOMER reports.
     - Example: 

5. To match a known motif result to the original known motif, is it sufficient to match motif name and consensus sequence (accounting for IUPAC nucleotide ambiguity codes)?
   - In practice, this has been sufficient.
   - Unclear if ["part 2" of motif local optimization](http://homer.ucsd.edu/homer/introduction/motifDetails.html) may change a nucleotide completely from the motif seed.

## References

How motif libraries are used: bin/findMotifs.pl > bin/HomerConfig.pm > `checkMSet()`

How motif libraries are constructed: update/updateMotifFiles.pl

<!---  --> 