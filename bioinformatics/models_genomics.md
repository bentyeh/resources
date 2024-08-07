# General Library Preparation and Sequencing Considerations

## Estimating Library Complexity

Consider a library of $M$ unique molecular species. Let subscript $i = 1, ..., M$ index these unique molecular species.
- Let $c_i$ denote the copy number of species $i$ in the library.
- Let $\pi_i$ denote the probability that an arbitrary read samples species $i$.
  - Generally, we assume uniform random sampling of reads from the library such that $\pi_i = \frac{c_i}{\sum_{j=1}^M c_j}$.
- Let $x_i(T)$ be a random variable giving the number of reads for species $i$ obtained from $T$ total reads.
  - Generally, we assume that $x_i$ are i.i.d. for all $i$. While this violates the constraint that $\sum_{i=1}^M x_i(T) = T$ (and relatedly, that $\sum_{i=1}^M \pi_i = 1$), this assumption should not significantly reduce accuracy of estimates in the regime that $x_i(T) \ll T$ for all $i$.

### Poisson

Assumption: all molecular species are equally represented - i.e., $\pi_i = 1 / M$ for all $i$.

Problem: Given $D$ unique (deduplicated) reads obtained from $T$ total reads, estimate $M$.

Approach
1. The expected number of reads per unique molecule is $\mathbb{E}(x_i) = \lambda = T / M$.
   - The analogous Binomial formulation is $T$ trials with probability $1/M$ of sampling species $i$ on any given trial.
2. The number of deduplicated molecules is $D = p(n \geq 1) \cdot M$.

If we assume a Poisson distribution for $n$,
$$p(n \geq 1) = 1 - p(n = 0) = 1 - \frac{\lambda^0 e^{-\lambda}}{0!} = 1 - e^{-\lambda} = 1 - e^{-T/M}$$

Then we obtain a non-linear equation with a single unknown, $M$:
$$D = p(n \geq 1) \cdot M = (1 - e^{-T/M}) \cdot M$$

Solve numerically:
```{python}
import scipy
D = <some measured value>
T = <some measured value>
scipy.optimize.minimize_scalar(
  fun=lambda M: (M * (1 - np.exp(-T/M)) - D)**2,
  bracket=(D, T)
)
```

<span style="color: red">Is this considered an MLE approach?</span>

Conceptually, one might consider the following MLE approach:
1. We observe read counts $x_i(T)$ for $i = 1, ..., D$ molecular species.
2. We perform MLE for a Poisson distribution using these read counts. The MLE estimator of $\lambda$ is just the mean read count
   $$\hat{\lambda} = \frac{1}{D} \sum_{i=1}^D x_i(T)$$
3. Then, we estimate $\hat{M} = T / \hat{\lambda}$.

This unfortunately does not work, since the MLE for a Poisson distribution requires knowing the counts for all species - i.e., the equation in step 2 above should be
$$\hat{\lambda} = \frac{1}{M} \sum_{i=1}^M x_i(T)$$

Unfortunately, we do not know what $M$ is (we are trying to solve for $M$). However, this conceptual approach can be adopted if we instead use a zero-truncated Poisson distribution instead.

### Zero-truncated Poisson

A zero-truncated Poisson distribution "is the conditional probability distribution of a Poisson-distributed random variable, given that the value of the random variable is not zero." [[Wikipedia](https://en.wikipedia.org/wiki/Zero-truncated_Poisson_distribution)]

We can derive the probability mass function $g(k; \lambda)$ from a standard Poisson distribution $f(k; \lambda)$:

$$
g(k; \lambda)
= P(X = k \mid X \gt 0)
= \frac{f(k; \lambda)}{1 - f(0; \lambda)}
= \frac{\lambda^k e^{-\lambda}}{k! (1 - e^{-\lambda})}
= \frac{\lambda^k}{k! (e^\lambda - 1)}
$$

The mean is $\mathbb{E}(X) = \frac{\lambda}{1 - e^{-\lambda}}$.

The method of moments estimator $\hat{\lambda}$ for parameter $\lambda$ (where $\lambda$ is the parameter of the underlying Poisson distribution) is obtained by solving the equation

$$
\frac{\hat{\lambda}}{1 - e^{-\hat{\lambda}}} = \bar{x}
$$

where $\bar{x} = \sum_{i=1}^D x_i(T)$ is the sample mean *of the observed counts*.

Solve numerically:
```{python}
import scipy

# implementation 1
lb = <some lower bound >= 0>
counts_mean = <mean observed counts>
T = <total number of reads>
res = scipy.optimize.minimize_scalar(
  fun=lambda l: (l / (1 - np.exp(-l)) - counts_mean)**2,
  bracket=(lb, counts_mean)
)
T / res.x

# implementation 2 (equivalent results)
ub = <some upper bound >= count_total / count_mean>
counts_mean = <mean observed counts>
T = <total number of reads>
res = scipy.optimize.minimize_scalar(
  fun=lambda M: ((T / M) / (1 - np.exp(-T / M)) - counts_mean)**2,
  bracket=(T / counts_mean, ub)
)
res.x
```

# RNA-Seq

Library preparation assumptions
- The total amount of DNA on a flow cell is constant

edgeR
- [[Robinson and Oshlack, 2010]](https://doi.org/10.1186/gb-2010-11-3-r25)
  - Shouldn't $M_{gk}^r = \log_2(\frac{\frac{Y_{gk}}{N_k}}{\frac{Y_{gr}}{N_r}})$? How are $M_g$ and $M_{gk}^r$ related?
  - How is the formula for $w_{gk}^r$ derived? Is $w_{gk}^r = \frac{1}{Var(M_g)}$?
  - In the Poisson model, shouldn't $Y_{gk} \sim Pois(\lambda_{gz_k} N_k)$ instead of $Y_{gk} \sim Pois(\lambda_{gz_k} M_k)$?
- [[edgeR User's Guide, 2019]](https://bioconductor.org/packages/release/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf)
  - 2.8.2 Biological coefficient of variation (BCV): If $E(y_{gi}) = \mu_{gi}$ and $y_{gi}$ follows a Poisson distribution, then isn't $y_{gi} \sim Poisson(\mu_{gi})$ and $Var(y_{gi}) = \mu_{gi}$?

References
- [Illumina TruSeq RNA Sample Preparation v2 Guide](https://support.illumina.com/content/dam/illumina-support/documents/documentation/chemistry_documentation/samplepreps_truseq/truseqrna/truseq-rna-sample-prep-v2-guide-15026495-f.pdf)

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