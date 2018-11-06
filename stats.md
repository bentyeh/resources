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

**Family-Wise Error Rate (FWER)**: $P(\text{at least one $H_0$ rejected}) = P(\text{one or more false positives})$
- The probability of one or more false positives among the rejected (null) hypotheses

**False Discovery Rate (FDR)**: $E(Q) = E(\frac{V}{R})$, where $V$ is the number of false positives, and $R$ is the total number of positives
- The expected proportion of errors among the rejected hypotheses

**Procedure**: method or criteria for rejecting a (null) hypothesis

**Control**: For any procedure, if the FDR or FWER is known to be less than $\alpha$, then the procedure is said to control the FDR or FWER error rate to level $\alpha$. 
- **Strong control**: a procedure can control the error rate regardless of the proportion of null hypotheses among all hypotheses
- **Weak control**: a procedure can only be proven to control the error rate when all hypotheses are null

**$q$-value**: $\hat{q}(p_i) = \min_{t \geq p_i} \hat{\text{FDR}}(t)$, where $\hat{\text{FDR}}(t)$ is the estimated FDR when calling all features significant whose $p$-value is less than or equal to some threshold $t$, where $0 < t \leq 1$.
- The minimum FDR that can be attained when calling a statistic significant.
- Suppose that features with $q$-values ≤ 5% are called significant. This results in a FDR of 5% among the significant features.

## Procedures

Variables
- $n$: number of hypotheses tested
- $\alpha$: significance level of individual test
- $\alpha^*$: multiple testing error rate
- $p_i$: uncorrected $p$-value of $i$th test
- $\tilde{p_i}$: adjusted $p$-value of $i$th test

### FWER

#### Bonferroni

Procedure: Reject all hypotheses where $\tilde{p_i} = np_i \lt \alpha^*$.

Background: Suppose that all null hypotheses are true and that each of $n$ null hypotheses is tested at level $\alpha$. Let $R_i$ denote the event that the $i$th null hypothesis is rejected. Then
$$\alpha^* = P(R_1 \cup R_2 \cup \cdots \cup R_n) \leq P(R_1) + P(R_2) + \cdots + P(R_n) = n\alpha$$

Rejection criteria: $p_i \lt \alpha = \frac{\alpha^*}{n} \rightarrow np_i \lt \alpha^*$

#### Šidák

Assumption: all individual tests are independent

Procedure: Reject all hypotheses where $\tilde{p_i} = 1 - (1 - p_i)^n < \alpha^*$.

Background:
$$ \alpha^* = P(\text{at least one $H_0$ rejected}) = 1 - P(\text{no $H_0$ rejected}) = 1 - \Pi_{i=1}^n P(p_i > \alpha) = 1 - \Pi_{i=1}^n (1 - \alpha) = 1 - (1 - \alpha)^n $$
$$ \alpha = 1 - (1 - \alpha^*)^{1/n} $$

Rejection criteria: $p_i \lt \alpha = 1 - (1 - \alpha^*)^{1/n} \rightarrow 1 - (1 - p_i)^n < \alpha^*$

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

#### Benjamini-Hochberg

Assumption: all individual tests are independent

Procedure: Consider testing $H_1$, $H_2$, ..., $H_n$ based on the corresponding $p$-values $P_1$, $P_2$, ..., $P_m$. Let $P_{(1)} \leq P_{(2)} \leq \cdots \leq P_{(n)}$ be the ordered $p$-values, and denote by $H_{(i)}$ the null hypothesis corresponding to $P_{(i)}$. Let $k$ be the largest $i$ for which $P_{(i)} \leq \frac{i}{m} \alpha^*$. Then reject all $H_{(i)}$ for $i = 1, 2, ..., k$.

Note: There may still be $i < k$ such that $P_{(i)} > \frac{i}{m} \alpha^*$.

Theorem: This procedure results in a FDR of $E(Q) = \frac{m_0}{m} \alpha^*$
- Since $\frac{m_0}{m} \alpha^* \leq \alpha^*$, this procedure strongly contorls the FDR at $\alpha^*$.
- See Benjamini and Hochberg (1995) or Ewens (2005) for a proof.

#### $q$-value

Properties
- Estimated $q$-values are increasing in the same order as the $p$-values.
- A procedure that rejects hypotheses with $q$-values < $\alpha^*$ controls the FDR error rate at $\alpha^*$.
