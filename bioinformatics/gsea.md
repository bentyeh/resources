# GSEA

Data
- Expression matrix
  - Rows: genes tested
  - Columns: samples (control1, control2, ..., cancer1, cancer2, ...)
- Gene sets

Algorithm
1. Rank genes according to differential expression
   - Rank according to fold-change between average (or median) expression between conditions
2. Use random walk to calculate enrichment score
   - Use index $i \in \{1, ..., n_\text{total}\}$ to denote ranked genes, where $i = 1$ corresponds to gene with largest positive fold-change
   - Use labels $y_i \in \{0, 1\}$ to denote whether ranked gene $i$ is in the gene set of interest
   $$p_\text{hit} = \sqrt{\frac{n_\text{total} - n_\text{gene set}}{n_\text{gene set}}}$$
   $$p_\text{miss} = -\sqrt{\frac{n_\text{gene set}}{n_\text{total} - n_\text{gene set}}}$$
   $$\text{ES} = \max_n \sum_{i=1}^n y_i p_\text{hit} + (1 - y_i) p_\text{miss}$$
   - For simplicity, the equation for $\text{ES}$ above only looks for positive enrichment, but can also look at the minimum value achieved during the random walk.
3. Estimate significance with permutation test
   - Permute column labels of expression matrix, recalculate enrichment score
4. Correct for multiple hypothesis testing (each gene set is a hypothesis)

Note that
$$\begin{aligned}
  \sum_{i=1}^{n_\text{total}} y_i p_\text{hit} + (1 - y_i) p_\text{miss}
  &= n_\text{gene set} p_\text{hit} + (n_\text{total} - n_\text{gene set}) p_\text{miss} \\
  &= \sqrt{n_\text{gene set} (n_\text{total} - n_\text{gene set})} - \sqrt{(n_\text{total} - n_\text{gene set}) n_\text{gene set}} \\
  &= 0
\end{aligned}$$

Reference: Stanford BMI 214, Lecture by Emily Flynn, 10/8/2019
