- [Multiple Testing](#multiple-testing)
  - [Definitions](#definitions)
  - [Procedures](#procedures)
    - [FWER](#fwer)
      - [Bonferroni](#bonferroni)
      - [Šidák](#%c5%a0id%c3%a1k)
    - [FDR](#fdr)
      - [Benjamini-Hochberg](#benjamini-hochberg)
      - [$q$-value](#q-value)
      - [Empirical Bayes: two-groups model](#empirical-bayes-two-groups-model)
    - [Weighted tests](#weighted-tests)
  - [Questions](#questions)
- [Shrinkage Estimation](#shrinkage-estimation)
  - [Over-dispersion of maximum likelihood estimate (MLE)](#over-dispersion-of-maximum-likelihood-estimate-mle)

<script>
document.getElementsByTagName("head")[0].getElementsByTagName("title")[0].innerHTML = "Statistics Notes";
</script>

# Multiple Testing

Textbooks
- Ewens, Warren J., and Gregory R. Grant. *Statistical Methods in Bioinformatics: An Introduction.* Springer Science & Business Media, 2005.
  - FWER and FDR in the context of Benjamini-Hochberg (1995) and Tusher (2001).
  - Does not discuss $q$-values.

Journal articles
- Benjamini, Yoav, and Yosef Hochberg. “Controlling the False Discovery Rate: A Practical and Powerful Approach to Multiple Testing.” Journal of the Royal Statistical Society: Series B (Statistical Methodology), vol. 57, no. 1, 1995, pp. 289–300, https://www.jstor.org/stable/2346101.
- Storey, John D. “A Direct Approach to False Discovery Rates.” Journal of the Royal Statistical Society: Series B (Statistical Methodology), vol. 64, no. 3, Aug. 2002, pp. 479–98, doi:10.1111/1467-9868.00346.
  - Estimating pFDR and FDR. Discussion of $q$-values.
- Storey, J. D., and R. Tibshirani. “Statistical Significance for Genomewide Studies.” Proceedings of the National Academy of Sciences, vol. 100, no. 16, Aug. 2003, pp. 9440–45, doi:10.1073/pnas.1530509100.
  - Discussion of $q$-values as an FDR-based measure of significance for genomewide studies.

## Definitions

**Family-Wise Error Rate (FWER)**: $P(\text{at least one } H_0 \text{ rejected}) = P(\text{one or more false positives})$
- The probability of one or more false positives among the rejected (null) hypotheses

**False Discovery Proportion (Fdp)**: $\frac{V}{R}$, where $V$ is the number of false positives, and $R$ is the total number of positives
- This value is never known in an experiment. However, we know its expectation:
- **False Discovery Rate (FDR)**: $E(Q) = E(\frac{V}{R})$: The expected proportion of errors among rejected hypotheses.

**Procedure**: method or criteria for rejecting a (null) hypothesis

**Control**: For any procedure, if the FDR or FWER is known to be less than $\alpha$, then the procedure is said to control the FDR or FWER error rate to level $\alpha$. 
- **Strong control**: a procedure can control the error rate regardless of the proportion of null hypotheses among all hypotheses
- **Weak control**: a procedure can only be proven to control the error rate when all hypotheses are null

**$q$-value**: $\hat{q}(p_i) = \min_{t \geq p_i} \hat{\text{FDR}}(t)$, where $\hat{\text{FDR}}(t)$ is the estimated FDR when calling all features significant whose $p$-value is less than or equal to some threshold $t$, where $p_i < t \leq 1$.
- The minimum FDR that can be attained when calling a statistic significant.
- Suppose that features with $q$-values ≤ 5% are called significant. This results in a FDR of 5% among the significant features.

## Procedures

Variables
- $m$: number of hypotheses tested
- $\alpha$: significance level of individual test
- $\alpha^*$: multiple testing error rate
- $p_i$: uncorrected $p$-value of $i$th test
- $\tilde{p_i}$: adjusted $p$-value of $i$th test

### FWER

#### Bonferroni

Assumption: none (does not require assumption that tests are independent)

Procedure: Reject all hypotheses where $\tilde{p_i} = mp_i \lt \alpha^*$.

Background: Suppose that all null hypotheses are true and that each of $m$ null hypotheses is tested at level $\alpha$. Let $R_i$ denote the event that the $i$th null hypothesis is rejected. Then
$$\alpha^* = P(R_1 \cup R_2 \cup \cdots \cup R_m) \leq P(R_1) + P(R_2) + \cdots + P(R_m) = m\alpha$$

Rejection criteria: $p_i \lt \alpha = \frac{\alpha^*}{m} \rightarrow mp_i \lt \alpha^*$

Adjusted $p$-value: $\tilde{p_i} = \mathrm{Adjust}_\mathrm{Bonferroni}(p_i, m) = mp_i$

#### Šidák

Assumption: all individual tests are independent

Procedure: Reject all hypotheses where $\tilde{p_i} = 1 - (1 - p_i)^m < \alpha^*$.

Background:
$$ \alpha^* = P(\text{at least one $H_0$ rejected}) = 1 - P(\text{no $H_0$ rejected}) = 1 - \Pi_{i=1}^m P(p_i > \alpha) = 1 - \Pi_{i=1}^m (1 - \alpha) = 1 - (1 - \alpha)^m $$
$$ \alpha = 1 - (1 - \alpha^*)^{1/m} $$

Rejection criteria: $p_i \lt \alpha = 1 - (1 - \alpha^*)^{1/m} \rightarrow 1 - (1 - p_i)^m < \alpha^*$

Adjusted $p$-value: $\mathrm{Adjust}_\mathrm{Šidák}(p_i, m) = 1 - (1 - p_i)^m$

### FDR

|             | Accept $H_0$ | Reject $H_0$ | Total   | 
|-------------|--------------|--------------|---------| 
| $H_0$ True  | $U$          | $V$          | $m_0$   | 
| $H_0$ False | $T$          | $S$          | $m-m_0$ | 
|             | $m-R$        | $R$          | $m$     | 

$$Q =
\begin{cases}
0, & \text{ if } V = R = 0 \\
V/R, & \text{ if } R > 0
\end{cases}$$

$$\text{FDR} = E(Q) = E(Q \mid R > 0)P(R > 0)$$

Basic properties
1. If all null hypotheses are true, then the FDR is equivalent to the FWER.
   - There can be no true positives (correct rejections), so $S = 0 \rightarrow V = R \rightarrow Q = 1$.
   - Then $E(Q) = \sum_{q} qp(q) = P(R > 0)= \text{FWER}$.
2. If some null hypotheses are not true, then $\text{FDR} < \text{FWER}$.
3. Controlling the FDR at $\alpha^*$ (as opposed to controlling the FWER at $\alpha^*$) increases power at the expense of Type I error rate.

#### Benjamini-Hochberg

Assumption: all individual tests are independent

Procedure: Consider testing $H_1$, $H_2$, ..., $H_m$ based on the corresponding $p$-values $p_1$, $p_2$, ..., $p_m$. Let $p_{(1)} \leq p_{(2)} \leq \cdots \leq p_{(m)}$ be the ordered $p$-values, and denote by $H_{(i)}$ the null hypothesis corresponding to $p_{(i)}$. Let $k$ be the largest $i$ for which $p_{(i)} \leq \frac{i}{m} \alpha^*$. Then reject all $H_{(i)}$ for $i = 1, 2, ..., k$.

Note: There may still be $i < k$ such that $p_{(i)} > \frac{i}{m} \alpha^*$.

Theorem: This procedure results in a FDR of $E(Q) = \frac{m_0}{m} \alpha^*$
- Since $\frac{m_0}{m} \alpha^* \leq \alpha^*$, this procedure strongly contorls the FDR at $\alpha^*$.
- See Benjamini and Hochberg (1995) or Ewens (2005) for a proof.

Adjusted p-value: $\tilde{p}_i = \mathrm{Adjust}_\mathrm{BH}(i, \vec{p}) = \min_{j \geq \mathrm{order(i)}} \frac{mp_{(j)}}{j}$
- Let $\vec{p} = (p_1, ..., p_m)$ be a sequence of $p$-values. Let $p_{(i)}$ denote the $i$th smallest p-value.
- Let $\mathrm{order}(i, \vec{p})$ give the rank (ascending; 1-indexed) of $p_i$
- Note: If $\mathrm{order}(i, \vec{p})$ gave the *descending* rank, then $\tilde{p}_i = \mathrm{Adjust}_\mathrm{BH}(i, \vec{p}) = \min_{j \leq \mathrm{order(i)}} \frac{mp_{(j)}}{j}$. This is the implementation used in R's [`p.adjust(p, method = "BH")`](https://svn.r-project.org/R/branches/R-3-6-branch/src/library/stats/R/p.adjust.R):
  ```{r}
  function(p) {
    n <- length(p)
    i <- n:1L
    o <- order(p, decreasing = TRUE)
    ro <- order(o)
    pmin(1, cummin(n/i * p[o]))[ro]
  }
  ```

#### $q$-value

Properties
- Estimated $q$-values are increasing in the same order as the $p$-values.
- A procedure that rejects hypotheses with $q$-values < $\alpha^*$ controls the FDR error rate at $\alpha^*$.

#### Empirical Bayes: two-groups model

<img id="p-value-dist" src="https://www.huber.embl.de/msmb/figure/chap14-mt-lfdr-1.png" alt="Density and distribution of p-values under two-groups model" style="float: right; margin: 0px 20px; object-fit: cover; object-position: top; max-width: 300px"/>

Consider $N$ cases that are either drawn from a null or non-null population with prior probability $\pi_0$ or $\pi_1 = 1 - \pi_0$. Each case is characterized by some statistic $z$ (Efron uses a z-score, but this could be any statistic). The distribution of statistics has density $f_0(z)$ (which is assumed / known) for null cases and density $f_1(z)$ (usually unknown *a priori*) for non-null cases. The observed distribution of statistics is therefore assumed to come from a mixture density
$$f(z) = \pi_0 f_0(z) + \pi_1 f_1(z)$$
and corresponding distribution (where $\mathcal{Z}$ denotes a set of $z$ values, usually $(-\infty, z)$ as in a CDF and as shown in the figure)
$$F(\mathcal{Z}) = \pi_0 F_0(\mathcal{Z}) + \pi_1 F_1(\mathcal{Z})$$

Here is what we know and don't know:
- Known
  - $f_0(z)$ and $F_0(\mathcal{Z})$: we assume a distribution for the null cases
- Unknown
  - $f(z)$ and $F(\mathcal{Z})$: we can substitute the *empirical* values $\bar{f}(z)$ and $\bar{F}(\mathcal{Z})$, which are just the *observed* distribution of statistics
  - $\pi_0$: we don't know the true value, but we have its upper bound of $1$
  - $f_1(z)$: unknown, but we do not need this to calculate the Bayes false discovery rate (local or for a region)

The Bayes false discovery rate $\mathrm{Fdr}(\mathcal{Z})$ (and its point estimate $\overline{\mathrm{Fdr}}(\mathcal{Z})$) is
$$
\mathrm{Fdr}(\mathcal{Z})
= P(\mathrm{null} \mid z \in \mathcal{Z})
= \frac{\pi_0 F_0(\mathcal{Z})}{F(\mathcal{Z})}
\approx \overline{\mathrm{Fdr}}(\mathcal{Z})
= \frac{\pi_0 F_0(\mathcal{Z})}{\bar{F}(\mathcal{Z})}
\leq \frac{F_0(\mathcal{Z})}{\bar{F}(\mathcal{Z})}
$$

The local Bayes false discovery rate is
$$
\mathrm{fdr}(z_0)
= P(\mathrm{null} \mid z = z_0)
= \frac{\pi_0 f_0(z_0)}{f(z_0)}
\approx \overline{\mathrm{fdr}}(z_0)
= \frac{\pi_0 f_0(z_0)}{\bar{f}(z_0)}
\leq \frac{f_0(z_0)}{\bar{f}(z_0)}
$$

Visual interpretation

|                | Using density (top figure)                                                       | Using distribution (bottom figure)                                                           |
| -------------- |:--------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------:|
| $\mathrm{FDR}$ | $\frac{\text{dark blue area}}{\text{dark blue + dark grey area}}$                | $\frac{\text{value of grey line at red segment}}{\text{value of blue curve at red segment}}$ |
| $\mathrm{fdr}$ | $\frac{\text{length of red segment above } \pi_0}{\text{length of red segment}}$ | n/a                                                                                          |

<div width="100%" style="clear: both"></div>

### Weighted tests

Motivation: Consider data whose $p$-values are differentially distributed according to a covariate. For a given $p$-value, the FDR for each subgroup will be different. A procedure (e.g., [Benjamini-Hochberg](#benjamini-hochberg) or [Bonferroni](#bonferroni)) that uses a global threshold will therefore have suboptimal power.

<img src="https://media.nature.com/lw926/nature-assets/nmeth/journal/v13/n7/images/nmeth.3885-F1.jpg"/>

Procedure: Let $w_i \ge 0$ and $\frac{1}{m} \sum_{i=1}^m w_i = 1$ (fixed total "weight budget"). Define weighted $p$-values $Q_i = \frac{p_i}{w_i}$. Apply unweighted procedure to the weighted $p$-values $Q_i$.

Guarantees: Controls type I error (FDR or FWER, depending on the unweighted procedure) at $\alpha$.

References
- Genovese, Christopher R., Kathryn Roeder, and Larry Wasserman. "False discovery control with p-value weighting." *Biometrika* 93.3 (2006): 509-524. https://doi.org/10.1093/biomet/93.3.509
- Ignatiadis, Nikolaos, et al. "Data-driven hypothesis weighting increases detection power in genome-scale multiple testing." *Nature Methods* 13.7 (2016): 577. https://doi.org/10.1038/nmeth.3885
- [R IHW package](https://bioconductor.org/packages/release/bioc/html/IHW.html) [vignette](https://bioconductor.org/packages/release/bioc/vignettes/IHW/inst/doc/introduction_to_ihw.html)

## Questions

1. What does it mean that the FDR is the expected value of false discoveries? What is the expectation taken over? Consider $n$ distinct experiments, each in which multiple hypothesis testing is performed at an FDR significance threshold of $\alpha^*$ such a fraction $q_i$ of the hypotheses rejected in experiment $i$ are erroneously rejected. Then $E(q_i) \leq \alpha^*$. But how are each of the $q_i$'s weighted? Are all experiments weighted equally (i.e., $\lim_{n \rightarrow \infty} \frac{1}{n} \sum_{i=1}^n q_i \leq \alpha^*$)? Or do the $n$ experiments have to be performed identically?

2. How is the frequentist (Benjamini-Hochberg) FDR related to Bayesian Fdr? Is the tail-area false discovery rate in section 6.10 of Modern Statistics for Modern Biology the Bayesian Fdr?

3. Are p-values statistics?
    - They are computed from samples.
    - They follow a (uniform) distribution.
    - The two-groups model of a Bayesian Fdr (as presented in MSMB) essentially determines whether a p-value is drawn from a null or non-null distribution. Note that Efron uses $z$-scores (definitely a statistic) in deriving the two-groups model, which would be analogous to p-values used in section 6.10 of MSMB.

4. How do you go from equation 6.14 to 6.15 in Efron's Computer Age Statistical Inference?

5. Why is the two-groups model considered an "empirical Bayes" method? Usually, "empirical Bayes" refers to estimating the prior from the data, but here, what's the prior?

# Shrinkage Estimation

## Over-dispersion of maximum likelihood estimate (MLE)

Consider the example from Chapter 7 of Efron and Hastie (2016):
$$\mathbf{\mu} \sim \mathcal{N}(\mathbf{M}, AI) \quad \text{and} \quad \mathbf{x} \mid \mathbf{\mu} \sim \mathcal{N}(\mu, I)$$
where $\mathbf{\mu} = (\mu_1, ..., \mu_N) \in \mathbb{R}^N$, $\mathbf{x} = (x_1, ..., x_N) \in \mathbb{R}^N$, and $\mathbf{M} = (M, ..., M) \in \mathbb{R}^N$. Then $\mu$ has a posterior distribution
$$\mu_i \mid x_i \sim \mathcal{N}(M + B(x_i - M), B), \quad B = \frac{A}{A + 1}$$
and $x_i$ has marginal distribution
$$x_i \sim_\mathrm{ind} \mathcal{N}(M, A + 1)$$

Some estimators for $\mathbf{\mu}$ are as follows:
- Maximum likelihood estimate (MLE): $\mathbf{\hat{\mu}}^\mathrm{MLE} = \mathbf{x}$
- Bayes: $\mathbf{\hat{\mu}}^\mathrm{Bayes} = \mathbf{M} + B(\mathbf{x} - \mathbf{M})$
- James-Stein: $\mathbf{\hat{\mu}}^\mathrm{JS} = \mathbf{\hat{M}} + \hat{B}(\mathbf{x} - \mathbf{\hat{M}})$
  - $\hat{M} = \bar{x}$ is an unbiased estimate of $M$
  - $\hat{B} = 1 - \frac{N-3}{S}, \quad S = \sum_{i=1}^N (x_i - \bar{x})^2$ is an unbiased estimate of $B$

Dispersion of MLE estimate
$$
E(\lvert\lvert \mathbf{x} \rvert\rvert_2^2)
= E \left( \sum_{i=1}^N x_i^2 \right)
= \sum_{i=1}^N E(x_i^2)
= \sum_{i=1}^N Var(x_i) + (E(x_i))^2
= N(A + 1 + M^2)
$$

$$
E(\lvert\lvert \mathbf{\mu} \rvert\rvert_2^2)
= E \left( \sum_{i=1}^N \mu_i^2 \right)
= \sum_{i=1}^N E(\mu_i^2)
= \sum_{i=1}^N Var(\mu_i) + (E(\mu_i))^2
= N(A + M^2)
$$

Even though each $x_i$ is unbiased ($E(x_i) = \mu_i$), as a group they are over-dispersed by an expected amount
$$E(\lvert\lvert \mathbf{x} \rvert\rvert_2^2) - E(\lvert\lvert \mathbf{\mu} \rvert\rvert_2^2) = N$$