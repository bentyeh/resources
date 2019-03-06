# ChIP-Seq

The number of reads in a genomic region should approximately follow a Poisson
distribution with mean $eM$ for regions containing a particular feature targeted by the ChIP-Seq assay and $M$ for the other (background) regions, where $M = \frac{R}{N(ef + (1-f))}$.

**Variables**
- $N$: number of non-overlapping fixed-size genomic regions
- $f$: proportion of *target regions* (regions containing a particular chromatin feature)
- $M$: expected number of reads per *background region* (regions lacking that particular chromatin feature)
- $e$: enrichment factor of reads in target bins such that the expected number of reads per target region is $eM$
- $R$: total number of sequencing reads

**Derivation / Explanation**

$$\begin{aligned}
\text{Total number of sequencing reads} &= \text{Number of reads in target regions} + \text{Number of reads in background regions} \\
&= (\text{Number of target regions} \times \text{Expected number of reads per target region}) + (\text{Number of background regions} \times \text{Expected number of reads per background region}) \\
R &= (Nf \times eM) + (N(1-f) \times M) \\
\rightarrow M &= \frac{R}{N(ef + (1-f))}
\end{aligned}$$

**Example**

Consider dividing the human genome (3 billion bp) into $N = 100,000,000$ non-overlapping 30 bp genomic regions. Consider a ChIP-Seq experiment generating $R = 1,000,000$ reads. Let $X$ be a random variable representing the number of reads belonging to a particular genomic region, say the first genomic region `chr1:1-30`.

A possible null (background) distribution is that a read is equally likely to belong to each genomic region, so the probability that a read belongs to `chr1:1-30` is $p_0 = \frac{1}{N} = 10^{-8}$. Thus, we have $H_0: X \sim \mathrm{Binomial}(R,p_0)$. Then, the expected number of reads belonging to `chr1:1-30` under the null distribution is $M = E(X) = Rp_0 = \frac{R}{N} = 0.01$. Since $R$ is large and $p_0$ is small, $X$ can be approximated by a Poisson distribution: $H_0: X \sim \mathrm{Poisson}(M)$, where $M = Rp_0 = 0.01$.

A possible alternative distribution (e.g., if we think that a genomic region is specifically targeted by a transcription factor) is that a read belongs to `chr1:1-30` with probability $p_A = ep_0$, so we get $H_A: X \sim \mathrm{Binomial}(R,ep_0)$, or approximately, $H_A: X \sim \mathrm{Poisson}(eM)$.

**Assumptions of Poisson model**
- $R$ is large.
  - Think of the alignment of each read as an independent trial.
- $N$ is large, so $p_0 = \frac{1}{N}$ and $p_A = ep_0$ are small.

**References**
- Mikkelsen, Tarjei S., et al. "Genome-wide maps of chromatin state in pluripotent and lineage-committed cells." *Nature* 448.7153 (2007): 553. https://doi.org/10.1038/nature06008.
  - The Poisson model is described in [Supplemental Information](https://media.nature.com/original/nature-assets/nature/journal/v448/n7153/extref/nature06008-s1.pdf).
- Zhang, Yong, et al. "Model-based analysis of ChIP-Seq (MACS)." *Genome Biology* 9.9 (2008): R137. https://doi.org/10.1186/gb-2008-9-9-r137
  - This paper presents the MACS ChIP-Seq peak-finding software which uses a dynamic Poisson model (incorporating local and global background distributions).