Notes on the HOMER (Hypergeometric Optimization of Motif EnRichment) "suite of tools for motif discovery and next-gen sequencing analysis." (http://homer.ucsd.edu/)

- [Peak calling](#peak-calling)
  - [FAQ](#faq)
  - [Unanswered questions](#unanswered-questions)
    - [How are control ("input") samples normalized by makeTagDirectory and findPeaks?](#how-are-control-input-samples-normalized-by-maketagdirectory-and-findpeaks)
    - [How to perform peak calling on paired-end data](#how-to-perform-peak-calling-on-paired-end-data)
- [Motif finding](#motif-finding)
  - [Usage ](#usage-)
  - [Motif library](#motif-library)
    - [Additional data/ files](#additional-data-files)
  - [Questions](#questions)
  - [References](#references)
  - [Changes to default 4.10 installation](#changes-to-default-410-installation)

# Peak calling

## FAQ

Which files in the tag directory does `findPeaks` actually use?
- `*.tags.tsv` and `tagInfo.txt`
- Source: source code (`findPeaks.cpp`, `SeqTag.cpp`) and trial-and-error. Removing/renaming each of the other files produced by `makeTagDirectory` (`tagAutocorrelation.txt`, `tagCountDistribution.txt`, `tagLengthDistribution.txt`) does not seem to affect `findPeaks`.

What does the `-totalReads <value>` option for the `makeTagDirectory` do?
- Unchanged files: `*.tags.tsv`, `tagAutocorrelation.txt`, `tagCountDistribution.txt`
- `tagLengthDistribution.txt`: `makeTagDirectory` first determines the correct read length distribution, but then for computing the average read length (`averageTagLength`), divides the count of reads at each read length by the user-provided `-totalReads <value>`. Consequently, if the user-provided value is not the true total number of reads, the read length distribution in `tagLengthDistribution.txt` does not sum to 1, but the values are proportional to the correct distribution.
  - Source code: `makeTagDirectory.cpp` creates a `SeqTag::TagLibrary` object and calls its method `SeqTag.cpp:TagLibrary::getTagLengthDistribution()`, which calls `SeqTag.cpp:ChrTags::getTagLengthDistribution()` to read the `*.tags.tsv` files and populate the count vector `dist` such that `dist[i]` is the number of reads with read length `i`. The probability mass at read length `i` is therefore `dist[i]` divided by the total number of reads. When `-totalReads <value>` is provided, the user-provided value is used as the total number of reads.
- `tagInfo.txt`
  - The 3rd column of the 2nd line is set to the user-provided value.
    - This has a dramatic effect on `findPeaks`. Based on the log messages produced by `findPeaks`, the identification of putative peaks is unaffected, but how putative peaks are filtered by comparison against the control sample is affected. See also the [FAQ below](#how-are-control-input-samples-normalized-by-maketagdirectory-and-findpeaks).
  - `fragmentLengthEstimate`: I have not looked into why this is affected by the user-provided `-totalReads <value>`.
  - `averageTagLength`: this is just the mean of the read length distribution calculated for `tagLengthDistribution.txt`
    - This does NOT appear to have an effect on `findPeaks`.

## Unanswered questions

### How are control ("input") samples normalized by makeTagDirectory and findPeaks?

By default, `findPeaks` normalizes read counts to 10,000,000 (see `-norm` option). Does this normalization only apply to read counts from the ChIP sample or also to read counts from the control sample?

Given that [HOMER's documentation](http://homer.ucsd.edu/homer/ngs/peaks.html) (as of 2025-02-27) notes that there is a sequencing-depth dependent step in filtering putative peak calls, what is best practice with generating / pre-processing control samples? For example, if the control sample was sequenced much more deeply than the ChIP sample, should it be downsampled first?

> HOMER uses two parameters to filter peaks against a control experiment.  First, it uses a fold change (which is sequencing depth-independent), requiring each putative peak to have 4-fold more normalized tags in the target experiment than the control (or specify a different fold change with "-F <#>").  In the case where there are no input tags near the putative peak, HOMER automatically sets these regions to be set to the average input tag coverage to avoid dividing by zero.  HOMER also uses the poisson distribution to determine the chance that the differences in tag counts are statistically significant (sequencing-depth dependent), requiring a cumulative poisson p-value of 0.0001 (change with "-P <#>").  This effectively removes peaks with low tag counts for which there is a chance the differential enrichment is found simply due to sampling error.

### How to perform peak calling on paired-end data

I have a dataset of aligned, paired-end ChIP-seq reads that were NOT generated using a strand-specific protocol. Since the read pairs simply indicate the ends of the chromatin fragment that was immunoprecipitated by my antibody, I figured that a 3-column BED file (chr, start, end) contains the same information as the BAM alignment file for the purpose of peak calling. The BAM file was already filtered for properly paired primary alignments (samtools view -f 3 -F 2828); I generated the BED file manually from the BAM file using pysam, where for each read pair I used the reference_start from the read that aligned on the ‘+’ strand and reference_end from the read that aligned on the ‘-‘ strand. Thus, the BED file has half as many entries as the BAM file by collapsing a pair of reads into a single genomic segment. In this case, what is the correct or most appropriate way to run `makeTagDirectory` – should I run `makeTagDirectory` using the BED file or the BAM file as input, and what options should I specify?
 
I tried running makeTagDirectory with default options using the BED file or BAM file:

`makeTagDirectory tagdirBED -genome hg38 align.bed`

or

`makeTagDirectory tagdirBAM -genome hg38 align.bam`

The `tagInfo.txt` file generated in each directory were different:
- Generated using input BED file:
  ```
  genome=hg38  1300437              1306880.0
  fragmentLengthEstimate=150
  peakSizeEstimate=150
  tagsPerBP=0.000428
  averageTagsPerPosition=1.005
  medianTagsPerPosition=1         
  averageTagLength=249.790
  gsizeEstimate=3056463931
  averageFragmentGCcontent=0.400
  ```
- Generated using input BAM file
  ```
  genome=hg38  2612483              1306880.0
  fragmentLengthEstimate=178
  peakSizeEstimate=521
  tagsPerBP=0.000428
  averageTagsPerPosition=0.000
  medianTagsPerPosition=0
  averageTagLength=61.691
  gsizeEstimate=3056491288
  averageFragmentGCcontent=0.400
  ```

Subsequent peak calling (findPeaks) and motif finding (findMotifsGenome.pl) yielded slightly different results on a high quality dataset, but results on a lower quality dataset led to completely different motifs found.

Is one approach more "correct" than the other? Any guidance is greatly appreciated!

# Motif finding

## Usage <a name="usage"></a>

Finding motifs
- log p-values outputed by findMotifs.pl in knownResults.txt or any of the \*.motif file outputs is the *natural* log p-value (source: compare p-value and log p-value of outputs)
- The hypergeometric p-value is calculated based on *estimates* of the number of sequences containing the motif in the target and background sets. Estimates are calculated identically but separately for target and background sets.
  - Let $n$ be the number of total sequences (either in the target or background set). Let $k_i$ be the estimated number of sequences containing the motif (such sequences can contain the motif 1 or more times) given the presence of $i$ matching instances (oligos) in $N$ total sequences. Then $k_i$ is computed recursively as

    $$
    \begin{aligned}
    k_1 &= 1 \\
    k_i &= k_{i-1} + \frac{n - k_{i-1}}{n}
    \end{aligned}
    $$

    This is why the "Number of Target/Background Sequences with motif" reported in homerResults/motif[#].info.html (*de novo* motifs) or knownResults.html (known motifs) are not necessarily integers and may be decimal numbers. When calcuating the hypergeometric p-value, these counts are rounded to the nearest integer.
  - Using these estimated number of sequences containing the motif, a 2x2 table can be constructed:

    |            | motif                 | no motif  | total |
    | ---------- | --------------------- | --------- | ----- |
    | Target     | $\hat{k}_\mathrm{target}$ | $n_\mathrm{target} - \hat{k}_\mathrm{target}$ | $n_\mathrm{target}$ |
    | Background | $\hat{k}_\mathrm{bg}$ | $n_\mathrm{bg} - \hat{k}_\mathrm{bg}$ | $n_\mathrm{bg}$ |
    | total      | $K = \hat{k}_\mathrm{target}$ + $\hat{k}_\mathrm{bg}$ | $n_\mathrm{target} + n_\mathrm{bg} - \hat{k}_\mathrm{target} - \hat{k}_\mathrm{bg}$ | $N = n_\mathrm{target} + n_\mathrm{bg}$

    The p-value represents $P(k \geq \hat{k}_\mathrm{target} \mid N, K, n_\mathrm{target})$.
    - An implementation in Python + scipy is provided below for an example motif occuring in $\hat{k}_\mathrm{target} = 15$ out of $n_\mathrm{target} = 40$ target sequences and $\hat{k}_\mathrm{bg} = 95$ out of $n_\mathrm{bg} = 1635$ background sequences.

      ```{python}
      k = 15
      n = 40
      K = 15 + 95
      N = 1635 + 40
      pvalue = 1 - scipy.stats.hypergeom.cdf(k - 1, N, n, K)
      # equivalently, scipy.stats.hypergeom.sf(k - 1, N, n, K)
      # equivalently, scipy.stats.fisher_exact([[k, n-k], [K - k, N - n - (K - k)]], alternative='greater').pvalue
      ```

  - Reference: [http://homer.ucsd.edu/homer/introduction/motifDetails.html](http://homer.ucsd.edu/homer/introduction/motifDetails.html)
- The "Consensus" sequence in knownResults.txt output may be different than the consensus sequence of the matched known motif in the library.
  - During ["part 2" of motif local optimization](http://homer.ucsd.edu/homer/introduction/motifDetails.html), the motifs are optimized (e.g., substituting in [IUPAC nucleotide ambiguity codes](https://en.wikipedia.org/wiki/Nucleic_acid_notation)) to achieve higher enrichment scores.

## Motif library

Overview
- Filename
  - known.motifs: used to check for known motif enrichment
    - HOMER motif library (data/knownTFs/motifs/\<mset>/\*.motif) + personal motif library (motifs/)
      - [vertebrates only] HOMER motif library = data/knownTFs/motifs/\*.motif
  - all.motifs: used to check against *de novo* motifs
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
- human.seq: +/- 2000 base pairs in each direction from the start of the RefSeq sequence

accession/: flat files for accession number conversion
- not included in the base installation: downloaded via `perl configureHomer.pl -install human-o`

## Questions

- What are all the threshold parameters?
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

- How is the log-odds threshold value in motif files used by HOMER?
  - A given sequence is considered to match a known motif if the calculated score (below) > log-odds threshold

    $$ \text{score} = \sum_{nt} \log \left( \frac{\text{observed}}{\text{expected}} \right) = \sum_{nt} \log \left( \frac{\text{probability of nt at corresponding position in motif matrix}}{0.25} \right) = \log \left( \frac{\Pi_{nt} P(\text{nt})}{0.25^{\text{length}(\text{motif})}} \right) $$

      - $\log$ of multiplying the probability of seeing each nucleotide (nt) at each position in the motif
      - HOMER fixes the log-odds expectation at 0.25 for each nucleotide
  - Used to find instances of motifs (e.g. of enriched known or *de novo* motifs)
  - Reference: [http://homer.ucsd.edu/homer/motif/creatingCustomMotifs.html](http://homer.ucsd.edu/homer/motif/creatingCustomMotifs.html)

- How are the log-odds threshold values calculated for found enriched motifs?
  - Known motifs: log-odds threshold from the library motif files are preserved.
  - *de novo* motifs: the threshold that results in the most significant enrichment
    - Reference: [http://homer.ucsd.edu/homer/introduction/motifDetails.html](http://homer.ucsd.edu/homer/introduction/motifDetails.html)

- How are enriched known motifs reported?
  - Background
    - A [motif name in a HOMER database](http://homer.ucsd.edu/homer/motif/motifDatabase.html) consists of the transcription factor name and the source of the motif (i.e., GEO accession number or publication author). Since a transcription factor may bind multiple consensus sequences (each representing a distinct motif), distinct motifs may share the same motif name.
    - Because of local optimization of seed motifs (see ["part 2" of motif local optimization](http://homer.ucsd.edu/homer/introduction/motifDetails.html)), a reported known motif (e.g., in knownResults.txt) may have a different consensus sequence than that of the known motif in the known motifs database (e.g., data/knownTFs/vertebrates/known.motifs).
  - Conclusion: There is no fail-proof way to create a 1:1 mapping from enriched known motifs to the original known motif in the known motifs database. One potential solution is to filter by motif name, consensus sequence length, and then consensus sequence similarity.

- [Unanswered] What is the default background set?
  - Is it just data/promoters/[species].base?
    - What determines the genes included in data/promoters/[species].base? What is the criteria for ["typically expressed or confident promoters"](https://homer.ucsd.edu/homer/introduction/update.html)?

- [Unanswered] In data/promoters/[species].pos, what does the 4th column (either 0 or 1) represent? Strand sense?

- [Unanswered] Define the following variables based on HOMER's output (i.e., from `knownResults.txt` and/or parsing `homerMotifs.all.motifs`):
  
  $$\begin{aligned}
  x_\text{target} &= \frac{\text{\# of Target Sequences with Motif}}{\text{\% of Target Sequences with Motif}} \times 100 \\
  y_\text{target} &= \text{round}(x_\text{target}) \\
  x_\text{background} &= \frac{\text{\# of Background Sequences with Motif}}{\text{\% of Background Sequences with Motif}} \times 100 \\
  y_\text{background} &= \text{round}(x_\text{background})
  \end{aligned}$$
  
  If we plot $\text{hist}(x_\text{target}-y_\text{target})$, we see a large peak around $0$ and very few values elsewhere in $[-0.5, 0.5]$. If we plot $\text{hist}(x_\text{background}-y_\text{background})$, we see essentially a uniform distribution in $[-0.5, 0.5]$. Why are the distributions different?

## References

How motif libraries are used: bin/findMotifs.pl > bin/HomerConfig.pm > `checkMSet()`

How motif libraries are constructed: update/updateMotifFiles.pl

## Changes to default 4.10 installation

Configuration
- Human promoters: `perl configureHomer.pl -install human-p`
- Update motif library: run update/updateMotifFiles.pl

Code
- bin/compareMotifs.pl: output proper HTML close tags
  - line 711: `<TR><TD>Score:</TD><TD>$score</TD></TR>` -- added ">" after `$score</TD`
  - line 712: `<TR><TD>Offset:</TD><TD>$matches->[$i]->{'offset'}</TD></TR>i` -- added ">" after `{'offset'}</TD`
- update/updateMotifFiles.pl
  - use latest JASPAR 2018 CORE PFMs (Position Frequency Matrices)
  - print to STDERR before it downloads JASPAR 2018 CORE PFMs

Library
- Renamed motifs/rorgt.motif to motifs/rorc.motif. Removed rorgt.motif from data/knownTFs/motifs.
  - motifs/rorgt.motif and data/knownTFs/motifs/rorc.motif were identical files.
  - motifs/rorgt.motif was copied over to data/knownTFs/motifs/ by update/updateMotifFiles.pl
- data/knownTFs/motifs/table.txt
  - removed extra tab ('\t') in line 311 (zpf3.motif) between last columns
- Renamed all instances of "ChIPSeq" to "ChIP-Seq" in all motif and related files
  - `find motifs/ -type f | xargs sed -i  's/ChIPSeq/ChIP-Seq/g'`
  - `find data/knownTFs/ -type f | xargs sed -i  's/ChIPSeq/ChIP-Seq/g'`
