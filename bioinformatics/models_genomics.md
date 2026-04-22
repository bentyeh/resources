Contents
- [General Library Preparation and Sequencing Considerations](#general-library-preparation-and-sequencing-considerations)
  - [Library Complexity](#library-complexity)
    - [Problem: Library Complexity Estimation](#problem-library-complexity-estimation)
      - [Binomial / Poisson](#binomial--poisson)
        - [Parameter estimation: maximum likelihood estimator (MLE)](#parameter-estimation-maximum-likelihood-estimator-mle)
      - [Zero-truncated Poisson](#zero-truncated-poisson)
        - [Parameter estimation: method of moments](#parameter-estimation-method-of-moments)
        - [Parameter estimation: maximum likelihood](#parameter-estimation-maximum-likelihood)
        - [Properties of the MLE and method-of-moments estimator](#properties-of-the-mle-and-method-of-moments-estimator)
    - [Problem: Optimizing number of reads to sequence](#problem-optimizing-number-of-reads-to-sequence)
- [RNA-Seq](#rna-seq)

# General Library Preparation and Sequencing Considerations

## Library Complexity

Consider a library of $M$ unique molecular species. Let subscript $i = 1, ..., M$ index these unique molecular species.
- Let $c_i$ denote the copy number of species $i$ in the library.
- Let $\pi_i$ denote the probability that an arbitrary read samples species $i$.
  - Generally, we assume uniform random sampling of reads from the library such that $\pi_i = \frac{c_i}{\sum_{j=1}^M c_j}$.
- Let $x_i(T)$ be a random variable giving the number of reads for species $i$ obtained from $T$ total reads.

### Problem: Library Complexity Estimation

Given $d$ unique (deduplicated) reads obtained from $T$ total reads, estimate $M$. Each unique read $j = 1, ..., d$ was observed $y_j(T)$ times, giving a histogram of counts. Given a function $\rho(j)$ that maps the index $j$ of a deduplicated read to its "original" index in the library, we have $y_j(T) = x_{\rho(j)}(T)$.

Below, I present a couple simple models for solving this problem. More sophisticated and accurate procedures exist, such as implemented by the [`preseq` package](https://github.com/smithlabcode/preseq) (see [Daley & Smith (2013)](https://doi.org/10.1038/nmeth.2375)).

TODO: what model is used by each of the following packages
- [`samtools markdup`](https://www.htslib.org/doc/samtools-markdup.html) (when used with `-s` flag): empirically matches what I get with the MLE of the zero-truncated Poisson model.
- [`picard EstimateLibraryComplexity`](https://gatk.broadinstitute.org/hc/en-us/articles/360037591931-EstimateLibraryComplexity-Picard)
  - According to Gemini, Picard uses the MLE of the Binomial/Poisson model.

#### Binomial / Poisson

Assumptions
- All molecular species are equally represented - i.e., $\pi_i = 1 / M$ for all $i$.
  - This model ignores library sampling steps (PCR cleanup, library pooling) that inevitably break this assumption.
  - TODO: If we assume perfect PCR amplification (no bias) and only consider post-PCR pre-sequencing sampling steps (PCR cleanup, library pooling), which themselves can be modeled as Binomial / Poisson, is the overall sampling procedure (pre-sequencing + sequencing) still Binomial / Poisson?
- $x_i$ are i.i.d. for all $i$.
  - While this violates the constraint that $\sum_{i=1}^M x_i(T) = T$ (and relatedly, that $\sum_{i=1}^M \pi_i = 1$), this assumption should not significantly reduce accuracy of estimates in the regime that $x_i(T) \ll T$ for all $i$.

Approach
1. We model the number of reads for each species $i$ as a binomial distribution with $T$ trials with probability $1/M$ of sampling species $i$ on any given trial: $x_i \sim \mathrm{Binomial}(n = T, p = 1/M)$.
   - The expected number of reads per species is $\mathbb{E}(x_i) = \lambda = T / M$.
   - The probability of not observing species $i$ is $P(x_i = 0) = {T \choose 0} \left(\frac{1}{M}\right)^0 \left(1 - \frac{1}{M}\right)^{T - 0} = \left(1 - \frac{1}{M}\right)^T$
   - Based on this model, the probability that a given species is observed at least once is

     $$P(x_i > 0) = 1 - P(x_i = 0) = 1 - \left(1 - \frac{1}{M}\right)^T \approx 1 - e^{-T/M}$$

     - The last approximation uses the Poisson distribution probability $P(x_i = 0) = \frac{\lambda^0 e^{-\lambda}}{0!} = e^{-T/M}$. Since $T$ is large and $1/M$ is small, the binomial distribution is well approximated by the Poisson distribution $x_i \sim \mathrm{Poisson}(\lambda = T/M)$.

2. The number of observed unique species is $D = \sum_{i=1}^M \mathbb{1}\{x_i(T) > 0\}$. Since $x_i$ are i.i.d. for all $i$,

   $$D \sim \mathrm{Binomial}\left(n = M, p = P(x_i > 0) = 1 - \left(1 - \frac{1}{M}\right)^T \approx 1 - e^{-T/M}\right)$$

   - The expected value is $\mathbb{E}(D) = M \left(1 - \left(1 - \frac{1}{M}\right)^T\right) \approx M (1 - e^{-T/M})$.
     - For $T \ll M$, an additional Poisson approximation can be used: $D \sim \mathrm{Poisson}(\lambda = M (1 - e^{-T/M}))$.

##### Parameter estimation: maximum likelihood estimator (MLE)

We cannot obtain the MLE for the parameter $\lambda = T/M$ for the distribution $x_i \sim \mathrm{Poisson}(\lambda = T/M)$. This is because the MLE
$$\hat{\lambda} = \frac{1}{M} \sum_{i=1}^M x_i(T)$$
depends on $M$, whose value we do not know! In other words, this MLE approach requires knowing the counts for all species $i = 1, ..., M$, not just the non-zero counts of species that we observed.

When $T \ll M$, however, we can obtain the MLE for the parameter $\lambda = M (1 - e^{-T/M})$ for the distribution $D \sim \mathrm{Poisson}(\lambda = M (1 - e^{-T/M}))$. This is not a robust estimation, as we only have one observation of the random variable $D$, namely $d$. Consequently, the MLE (which in this case is also the method of moments estimator) is simply $\hat{\lambda} = d$. Thus, $d = M (1 - e^{-T/M})$. We can numerically solve this non-linear equation for $M$:

```{python}
import scipy
d = <some measured value>
T = <some measured value>
scipy.optimize.minimize_scalar(
  fun=lambda M: (M * (1 - np.exp(-T/M)) - d)**2,
  bracket=(d, T)
)
```

#### Zero-truncated Poisson

Let $Y_j$ ($j = 1, ..., d$) be read counts for each unique species $j$, where $Y_j$ follows a zero-truncated Poisson distribution with parameter $\lambda$. Let $S = \sum_{j=1}^d Y_j$ and $\bar{Y} = \frac{S}{d}$.

A zero-truncated Poisson distribution "is the conditional probability distribution of a Poisson-distributed random variable, given that the value of the random variable is not zero." [[Wikipedia](https://en.wikipedia.org/wiki/Zero-truncated_Poisson_distribution)] We can derive the probability mass function $g(y_j; \lambda)$ from a standard Poisson distribution $f(y_j; \lambda)$:

$$
g(y_j; \lambda)
= P(Y_j = y_j \mid Y_j \gt 0)
= \frac{f(y_j; \lambda)}{1 - f(0; \lambda)}
= \frac{\lambda^{y_j} e^{-\lambda}}{y_j! (1 - e^{-\lambda})}
= \frac{\lambda^{y_j}}{y_j! (e^\lambda - 1)}
$$

The mean is $\mathbb{E}(Y_j) = \frac{\lambda}{1 - e^{-\lambda}} = \frac{\lambda e^\lambda}{e^\lambda - 1}$.

##### Parameter estimation: method of moments

Problem: Given mean observed counts per species $\bar{y}$ obtained from $T$ total reads, estimate $M$.

The method of moments estimator $\hat{\lambda}$ for parameter $\lambda$ (where $\lambda$ is the parameter of the underlying Poisson distribution) is obtained by solving the equation

$$
\frac{\hat{\lambda}}{1 - e^{-\hat{\lambda}}} = \bar{y}
$$

where $\bar{y} = \frac{1}{d} \sum_{i=1}^d y_j(T) = \frac{T}{d}$ is the sample mean *of the observed counts*.

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
ub = <some upper bound >= T / count_mean>
counts_mean = <mean observed counts>
T = <total number of reads>
res = scipy.optimize.minimize_scalar(
  fun=lambda M: ((T / M) / (1 - np.exp(-T / M)) - counts_mean)**2,
  bracket=(T / counts_mean, ub)
)
res.x
```

##### Parameter estimation: maximum likelihood

The likelihood is

$$
\mathcal{L}(\lambda)
= \prod_{j=1}^d P(Y_j = y_j)
= \prod_{j=1}^d \frac{\lambda^{y_j}}{y_j! (e^\lambda - 1)}
= (e^\lambda - 1)^{-d} \prod_{j=1}^d \frac{\lambda^{y_j}}{y_j!}
$$

The log-likelihood is therefore

$$
\begin{aligned}
\ln \mathcal{L}(\lambda)
&= \sum_{j=1}^d \ln P(Y_j = y_j) \\
&= -d \ln(e^\lambda - 1) + \sum_{j=1}^d y_j \ln(\lambda) - \ln(y_j!) \\
&= -d \ln(e^\lambda - 1) + \ln(\lambda) S - \sum_{j=1}^d \ln(y_j!)
\end{aligned}
$$

Differentiate and set to zero:

$$
\frac{d}{d\lambda} \ln \mathcal{L}(\lambda)
= -d \frac{e^\lambda}{e^\lambda -1} + \frac{S}{\lambda}
= 0
$$

Rearranging yields

$$
\frac{S}{d}
= \frac{\lambda e^\lambda}{e^\lambda - 1}
= \frac{\lambda}{1 - e^{-\lambda}}
\rightarrow
\bar{Y} = \frac{\hat{\lambda}}{1 - e^{-\hat{\lambda}}}
$$

which is the same estimator obtained by the method of moments.

##### Properties of the MLE and method-of-moments estimator

Let $\bar{y} = h(\lambda) = \frac{\lambda}{1 - e^{-\lambda}}$.
- Derivative: $h'(\lambda) = \frac{1 - e^{-\lambda} - \lambda e^{-\lambda}}{(1 - e^{-\lambda})^2}$
- Inverse: the estimator satisfies $\hat{\lambda} = h^{-1}(\bar{y})$.

Uniqueness of estimator: for any sample mean $\bar{y}$, there is a unique $\hat{\lambda} > 0$.
- Since $e^\lambda \geq 1 + \lambda$ (so $e^{-\lambda} \leq \frac{1}{1 + \lambda}$; note that equality only occurs at $\lambda = 0$), the numerator satisfies
  $$
  1 - e^{-\lambda} - \lambda e^{-\lambda}
  \geq 1 - \frac{1}{1 + \lambda} - \frac{\lambda}{1 + \lambda}
  = \frac{(1 + \lambda) - 1 - \lambda}{1 + \lambda}
  = 0
  $$
  so the numerator is always non-negative with equality only at $\lambda = 0$. The denominator is always non-negative, evaluating to 0 only at $\lambda = 0$. Therefore, $h'(\lambda) > 0$ for $\lambda > 0$: $h$ is a strictly increasingly of function of $\lambda$ for $\lambda > 0$.
  - Derivation that $e^\lambda \geq 1 + \lambda$: let $A(\lambda) = e^\lambda - 1 - \lambda$. By its first derivative $A'(\lambda) = e^\lambda - 1$, we see that $A$ is increasing for $\lambda > 0$ and equal to 0 at $\lambda = 0$.

- Bias: $\mathbb{\hat{\lambda}}$ is a finite-sample biased but asymptotically unbiased estimator of $\lambda$.
  - $\bar{y}$ is an unbiased estimator of the mean $\mathbb{E}(\bar{y}) = \mathbb{E}(Y_j)$. However, because $h^{-1}$ is nonlinear,
  $$
  \mathbb{E}(\hat{\lambda}) = \mathbb{E}(h^{-1}(\bar{y})) \neq h^{-1}(\mathbb{E}(\bar{y})) = h^{-1}(\mathbb{E}(Y_j)) = \lambda
  $$
  - Jensen's inequality?
  - Consistency?

- Variance: the asymptotic variance is $\mathrm{Var}(\hat{\lambda}) \approx \frac{1}{d I(\lambda)} \approx \frac{\hat{\lambda} (1 - e^{-\hat{\lambda}})^2}{d \left(1 - e^{-\hat{\lambda}} - \hat{\lambda} e^{-\hat{\lambda}} \right)}$
  - Theory: Under smoothness conditions on $P(Y_j = y_j) = g(y_j; \lambda)$, $\hat{\lambda}_\text{MLE}$ tends to $\mathcal{N}\left(\lambda, \frac{1}{d I(\lambda)}\right)$.
  - Fisher information: $I(\lambda) = \frac{1 - e^{-\lambda} - \lambda e^{-\lambda}}{\lambda (1 - e^{-\lambda})^2}$
    <!-- <details> -->

    - First compute the second derivative of the single-observation log-likelihood:
      $$
      \begin{aligned}
      \ln \mathcal{L}_1(\lambda)
      &= \ln \left(P(Y_j = y) \right) \\
      &= \ln \left( \frac{\lambda^{y}}{y! (e^\lambda - 1)} \right) \\
      &= y \ln (\lambda) - \ln (y!) - \ln(e^\lambda - 1) \\

      \rightarrow \frac{d}{d\lambda} \ln \mathcal{L}_1(\lambda)
      &= \frac{y}{\lambda} - e^\lambda (e^\lambda - 1)^{-1} \\

      \rightarrow \frac{d^2}{d\lambda^2} \ln \mathcal{L}_1(\lambda)
      &= -\frac{y}{\lambda^2} - e^\lambda (-1)(e^\lambda - 1)^{-2} e^\lambda - e^\lambda(e^\lambda - 1)^{-1} \\
      &= -\frac{y}{\lambda^2} + e^{2\lambda} (e^\lambda - 1)^{-2} - e^\lambda (e^\lambda - 1) (e^\lambda - 1)^{-2} \\
      &= -\frac{y}{\lambda^2} + e^{2\lambda} (e^\lambda - 1)^{-2} - (e^{2\lambda} - e^{\lambda}) (e^\lambda - 1)^{-2} \\
      &= -\frac{y}{\lambda^2} + \frac{e^{\lambda}}{(e^\lambda - 1)^2}
      \end{aligned}
      $$
    - Take its negative expectation and use the expression for the mean of the zero-truncated Poisson $\mathbb{E}(Y_j)$
      $$
      \begin{aligned}
      I(\lambda)
      &= -\mathbb{E}\left(\frac{d^2}{d\lambda^2} \ln \mathcal{L}_1(\lambda)\right) \\
      &= -\mathbb{E}\left(-\frac{y}{\lambda^2} + \frac{e^{\lambda}}{(e^\lambda - 1)^2}\right) \\
      &= \frac{\mathbb{E}(Y_j)}{\lambda^2} - \frac{e^{\lambda}}{(e^\lambda - 1)^2} \\
      &= \frac{\lambda e^\lambda}{\lambda^2 (e^\lambda - 1)} - \frac{e^{\lambda}}{(e^\lambda - 1)^2} \\
      &= \frac{\lambda e^\lambda (e^\lambda - 1) - \lambda^2 e^{\lambda}}{\lambda^2 (e^\lambda - 1)^2} \\
      &= \frac{\lambda e^\lambda (e^\lambda - 1 - \lambda)}{\lambda^2 (e^\lambda - 1)^2} \\
      &= \frac{e^\lambda (e^\lambda - 1 - \lambda)}{\lambda (e^\lambda - 1)^2} \\
      \end{aligned}
      $$
      - Note that this expression for the Fisher information can be expressed in terms of $e^{-\lambda}$ instead of $e^\lambda$ as follows: Let $x = e^\lambda$, so $1/x = e^{-\lambda}$. Then
        $$
        \begin{aligned}
        I(\lambda)
        &= \frac{x (x - 1 - \lambda)}{\lambda (x - 1)^2} \\
        &= \frac{x (x - 1 - \lambda) x^{-2}}{\lambda (x - 1)^2 x^{-2}} \\
        &= \frac{(x - 1 - \lambda)/x}{\lambda (\frac{x - 1}{x})^2} \\
        &= \frac{1 - 1/x - \lambda/x}{\lambda (1 - 1/x)^2} \\
        &= \frac{1 - e^{-\lambda} - \lambda e^{-\lambda}}{\lambda (1 - e^{-\lambda})^2}
        \end{aligned}
        $$
    - The asymptotic variance of the maximum likelihood estimator is
      $$
      \mathrm{Var}(\hat{\lambda})
      \approx \frac{1}{d I(\lambda)}
      = \frac{\lambda (1 - e^{-\lambda})^2}{d \left(1 - e^{-\lambda} - \lambda e^{-\lambda} \right)}
      $$
      In practice, the plug-in estimator is used:
      $$
      \widehat{\mathrm{Var}(\hat{\lambda})}
      = \frac{1}{d I(\hat{\lambda})}
      = \frac{\hat{\lambda} (1 - e^{-\hat{\lambda}})^2}{d \left(1 - e^{-\hat{\lambda}} - \hat{\lambda} e^{-\hat{\lambda}} \right)}
      $$
  - Delta method: TODO
  - Confidence intervals: For large samples (i.e., large $d$), we can substitute $I(\hat{\lambda})$ for $I(\lambda)$ and get
    $$
    P\left( -z_{\alpha/2} \leq \sqrt{d I(\hat{\lambda})}(\hat{\lambda} - \lambda) \leq z_{\alpha/2} \right)
    = P\left( \lambda - \frac{z_{\alpha/2}}{\sqrt{d I(\hat{\lambda})}} \leq \hat{\lambda} \leq \lambda + \frac{z_{\alpha/2}}{\sqrt{d I(\hat{\lambda})}} \right)
    $$

  <!-- </details> -->

The steps above give us an estimator $\hat{\lambda}$ for the parameter $\lambda$ of the (zero-truncated) Poisson model of read counts of individual molecular species. Now, we want to use the estimator $\hat{\lambda}$ to estimate library complexity $M$. The true parameters $\lambda$ and $M$ are related by $M = q(\lambda) = T / \lambda$. (From Gemini) By the functional invariance property of the MLE, the MLE of $M$ is
$$\hat{M}_\text{MLE} = q(\hat{\lambda}_\text{MLE}) = \frac{T}{\hat{\lambda}_\text{MLE}}.$$
- TODO: explain / derive the functional invariance property of MLE.
- Relevant equalities
  - First derivative: $q'(\hat{\lambda}) = -\frac{T}{\hat{\lambda}^2}$
  - Inverse: $\hat{\lambda} = q^{-1}(\hat{M}) = T / \hat{M}$
- Consistency
  - TODO: For a fixed true $M$, does $\hat{M}$ converges to $M$ as $T \rightarrow \infty$?
  - TODO: For a fixed $T$, how does $\hat{M}$ behave as $M \rightarrow \infty$?
- Bias: $\hat{M}$ is biased.
  - The function $q(\hat{\lambda}) = T / \hat{\lambda}$ is strictly convex for $\hat{\lambda} > 0$. Consequently, by Jensen's inequality, $q(\mathbb{E}(\hat{\lambda})) < \mathbb{E}(q(\hat{\lambda}))$, or $\frac{T}{\mathbb{E}(\hat{\lambda})} < \mathbb{E}(\hat{M})$.
  - TODO: show that this means that $\mathbb{E}(\hat{M}) \neq M$
- Variance
  - Delta method
    $$
    \begin{aligned}
    \mathrm{Var}(\hat{M})
    &\approx [q'(\hat{\lambda})]^2 \mathrm{Var}(\hat{\lambda}) \\
    &\approx \left(-\frac{T}{\hat{\lambda}^2} \right)^2 \frac{1}{d I(\hat{\lambda})} \\
    &= \frac{T^2}{d \hat{\lambda}^4 I(\hat{\lambda})} \\
    &= \frac{T^2 (1 - e^{-\hat{\lambda}})^2}{d \hat{\lambda}^3 \left(1 - e^{-\hat{\lambda}} - \hat{\lambda} e^{-\hat{\lambda}} \right)}
    \end{aligned}
    $$
  - Confidence intervals: Gemini suggests that a confidence interval can be constructed as $\hat{M} \pm z_{\alpha/2} \sqrt{\frac{T^2}{d \hat{\lambda}^4 I(\hat{\lambda})}}$.
    - TODO: Is this valid?
- Is this the best estimator for $M$?
  - TODO: Are there more efficient estimators of $M$?
    - Note that the MLE is already asymptomtically efficient.
  - TODO: Are there unbiased estimators for $M$?

### Problem: Optimizing number of reads to sequence

Given a library complexity $M$ and total reads $T$, estimate the number of observed unique molecules $d$. In other words, generate the observed complexity curve (number of unique molecules observed as a function of reads sequenced).

Using the Binomial model presented previously, we get

$$D \sim \mathrm{Binomial}\left(n = M, p = 1 - \left(1 - \frac{1}{M}\right)^T\right)$$

with expected value $\mathbb{E}(D) = M \left(1 - \left(1 - \frac{1}{M}\right)^T\right)$.

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