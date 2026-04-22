---
title: Variance decomposition
---

# Variance decomposition

Definitions
- Conditional distributions
  - Discrete

    $$p_{Y \mid X}(y \mid x) = P(X = x \mid Y = y) = \frac{p_{XY}(x, y)}{p_Y(y)}$$

  - Continuous

    $$f_{Y \mid X}(y \mid x) = f(X = x \mid Y = y) = \frac{f_{XY}(x, y)}{f_Y(y)}$$

- Conditional expectation
  - Discrete

    $$E(h(Y) \mid X = x) = \sum_y h(y) p_{Y \mid X} (y \mid x)$$

  - Continuous

    $$E(h(Y) \mid X = s) = \int h(y) f_{Y \mid X}(y \mid x) dy$$

- Condition variance

  $$V(Y \mid X = s) = E(Y^2 \mid X = s) - [E(Y \mid X = x)]^2$$

The conditional expectation $E(Y \mid X)$ and the conditional variance $V(Y \mid X)$ are themselves random variables that are functions of $X$ (assuming that $Y \mid X = x$ exists for every $x$ in the range of $X$).

Theorems
- Law of total expectation: $E(Y) = E(E(Y \mid X))$
  - Explanation: The outer expectation is taken with respect to the distribution of $X$. Thus, the expected value of $Y$ can be found by first conditioning on X, finding $E(Y |X)$, and then averaging this quantity with respect to $X$.
  - Proof (discrete case)

    ```math
    \begin{aligned}
    E(E(Y \mid X))
    &= \sum_x p_X(x) E(Y \mid X = x) \\
    &= \sum_x p_X(x) \sum_y p_{Y \mid X} (y \mid x) y \\
    &= \sum_x \sum_y p_X(x) p_{Y \mid X} (y \mid x) y \\
    &= \sum_y \sum_x p_X(x) p_{Y \mid X} (y \mid x) y \\
    &= \sum_y y \sum_x p_X(x) p_{Y \mid X} (y \mid x) \\
    &= \sum_y y p_Y(y) \\
    &= E(Y)
    \end{aligned}
    ```
- Law of total variance: $V(Y) = E(V(Y \mid X)) + V(E(Y \mid X))$
  - Explanation (inspired by [Wikipedia](https://en.wikipedia.org/wiki/Law_of_total_variance)): For a given value of $X = x$, $E(Y \mid X = x)$ and $V(Y \mid X = x)$ are constant numbers. Thus, we can think of the possible values of $X$ as "grouping" the potential outcomes of $Y$. We then compute the expected values $E(Y \mid X)$ and variances $V(Y \mid X)$ for each group. The total variance of $Y$ is the sum of 2 parts:
    - "Unexplained variance" $E(V(Y \mid X))$: the average of all the variances of $Y$ within each group.
    - "Explained variance" $V(E(Y \mid X))$: the variance of the expected values across all groups.
  - Proof

    ```math
    \begin{aligned}
    V(Y)
    &= E(Y^2) - [E(Y)]^2 \\
    &= E(E(Y^2 \mid X)) - [E(E(Y \mid X))]^2 \\
    &= E(E(Y^2 \mid X)) - \underbrace{E([E(Y \mid X)]^2) + E([E(Y \mid X)]^2)}_\text{adding 0} - [E(E(Y \mid X))]^2 \\
    &= E(E(Y^2 \mid X) - [E(Y \mid X)]^2) + V(E(Y \mid X)) \\
    &= E(V(Y \mid X)) + V(E(Y \mid X))
    \end{aligned}
    ```

Reference: Rice, John A. *Mathematical Statistics and Data Analysis, Third Edition.* Duxbury, 2007.