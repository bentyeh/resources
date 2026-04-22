---
title: Estimators
---

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