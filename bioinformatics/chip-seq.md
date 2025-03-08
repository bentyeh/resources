
# Fragment size estimation

Fragment size can be directly measured
- Gel electrophoresis methods: e.g., traditional agarose gel, ScreenTape, or BioAnalyzer assays
- Paired-end sequencing

Unique to ChIP-seq (and similar) data, fragment size can also be estimated from single-end sequencing reads.
- MACS approach: "Since ChIP-DNA fragments are equally likely to be sequenced from both ends, the tag density around a true binding site should show a bimodal enrichment pattern"
  - This is because the protein crosslinked to DNA protects the directly bound DNA sequence. Let the $X$ be the position of plus strand 5' end of fragments bound by the target protein. Let $Y$ be the fragment length distribution. Then, the position of 3' end of fragments bound by the target protein is $X + Y$; this is reflected in minus-strand reads. Thus, we know the distribution of $X$ and of $X + Y$. By linearity of expectation, $E[Y] = E[X + Y] - E[X]$.
  - If we further assume that $X$ and $Y$ are independent, then we can actually recover the full distribution of $Y$:

    $$
    f_Y(y) = \mathcal{L}^{-1} \left[\frac{\mathcal{L}(f_{X+Y})}{\mathcal{L}(f_X)} \right](y)
    $$




# Differential peak calling

## Scaling coverage between conditions for peak calling

This is copied from my MACS GitHub Discussions post: https://github.com/macs3-project/MACS/discussions/694

In the [original 2008 MACS paper by Zhang et al.](https://doi.org/10.1186/gb-2008-9-9-r137), the authors write

> we notice that when tag counts from ChIP and controls are not balanced, the sample with more tags often gives more peaks even though MACS normalizes the total tag counts between the two samples ... we await more available ChIP-Seq data with deeper coverage to understand and overcome this bias

This is actually to be expected given MACS's Poisson model.

Let $X$ be the coverage at some peak in the ChIP track. Let $\lambda$ be the coverage at that peak in the control track. Let $f$ be the sequencing depth ratio between samples, i.e., total number of reads in the ChIP sample / total number of reads in the control sample. If scaling the ChIP track to match the control track, then the scaled coverage ratio at the peak is $r = (X / f) / \lambda = X / (\lambda f)$. If scaling the control track to match the ChIP track, then the ratio is $r = X / (\lambda f)$. The scaled ratio is therefore identical regardless of which direction the scaling is performed.

For a constant ratio of a sample value to the mean of a Poisson distribution, the p-value (or 1 - CDF) decreases as the mean increases. While [this can be observed by simulation](https://colab.research.google.com/drive/1hGZqwXf_LhlRVupKsLiG525TZQ6xnLm6), it can also be intuitively understood as follows:
- In a Poisson distribution, the standard deviation grows with the square-root of the mean. Therefore, for a constant ratio of sample value-to-mean, the distance (in units of standard deviation) between the sample value and the mean increases as the mean increases.
  - The number of standard deviations away from the mean does not alone determine a p-value when using a Poisson distribution. However, to further our intuitive understanding, we can consider the case of large mean (e.g., $λ \ge 1000$), when a Poisson distribution becomes very accurately approximated by a Normal distribution (see [Wikipedia](https://en.wikipedia.org/wiki/Poisson_distribution#General)), which does have the property that p-values are uniquely determined by the number of standard deviations away from the mean. The z-score, given constant ratio $r$, increases (and p-value decreases) as the scaled local coverage $\lambda$ increases:

$$z(r, \lambda) = \frac{r\lambda - \lambda}{\sqrt{\lambda}} = (r-1) \sqrt{\lambda}$$

Consequently, using a higher control coverage value $\lambda$ (whether by scaling up a low-depth control to match a high-depth ChIP sample, or by scaling up a low-depth ChIP sample to match a high-depth control sample) results in lower p-values for all peaks and therefore more peaks passing cutoff.

## MACS3 likelihood ratio

Define coverage as the average number of (extended and shifted) reads overlapping each position (base) in a region. (The genome-wide coverage is therefore # of reads * fragment length / genome size.) Let $X$ be the coverage for a given region.

MACS assumes $X$ follows a Poisson distribution, such that the likelihood of observing $X = x$ given expected coverage $\lambda$ is

$$
P(X = x \mid \lambda) = \frac{\lambda^x e^{-\lambda}}{x!}
$$

where expected coverage is derived from a control or input track.

For comparing 2 samples with depth-normalized coverage $X = x$ and $Y = y$ at a given candidate peak, the documentation (and [a GitHub issue comment from the author](https://github.com/macs3-project/MACS/issues/681#issuecomment-2670423801)) for `macs3 bgdiff` suggests that MACS uses multi-way likelihood ratio comparisons to both call peaks and determine whether it is enriched in one ChIP sample versus another. Specifically, the likelihood ratio used by MACS is the ratio of the probability of observing $X = x$ given mean $\lambda = x$ to the probability of observing $X = x$ given mean $\lambda = y$:

$$
L
= \frac{P(X = x \mid \lambda = x)}{P(X = x \mid \lambda = y)}
= \frac{x^x e^{-x} / x!}{y^x e^{-y} / x!}
= e^{y-x} (x/y)^x
$$

The log likelihood ratio is therefore

$$
\ln{L} = (y-x) + x(\ln(x) - \ln(y))
$$

The numerator is really just the probability mass at the expected value of a Poisson distribution where the expected value is set to the observed coverage in sample 1. The denominator is the probability mass of the observed coverage in sample 1 given an expected value based on the observed coverage in sample 2.

It is not clear to me how using a cutoff of this likelihood ratio is a better way of peak-calling than using a cutoff of a p-value simply based on the denominator.


# Resources

Differential binding
- see https://github.com/macs3-project/MACS/wiki/Call-differential-binding-events


https://nbis-workshop-epigenomics.readthedocs.io/en/latest/index.html

https://yulab-smu.top/biomedical-knowledge-mining-book/index.html

https://www.bioconductor.org/packages/release/bioc/vignettes/ChIPseeker/inst/doc/ChIPseeker.html


https://hbctraining.github.io/main/

https://hbctraining.github.io/Intro-to-ChIPseq/

https://jserizay.com/Bioc2024tidyworkshop/index.html

https://www.youtube.com/watch?v=eSwtF1t3uCw
