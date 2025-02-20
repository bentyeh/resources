# Base R

## Modeling

### Simple model

Consider a simple linear model

$$y = \beta_0 + x_1 \beta_1$$

- $y$: experimental measurement of interest (say, RNA-seq counts of a given gene)
- $x_1$: factor indicating the condition (e.g., treatment versus control) of a sample
- $\beta_0$: intercept
- $\beta_1$: slope

If there are only two conditions, then $x_1$ becomes a binary indicator variable

$$x_1 = \begin{cases} 0, &\text{control} \\ 1, &\text{treatment} \end{cases}$$

and we can interpret $\beta_0$ as the base level of the measurement in the control condition and $\beta_1$ as the difference between treatment and control.

However, what if there are more than 2 conditions? What if $x_1$ is a factor representing, say, 10 different treatment conditions? Since we want to estimate a different effect from each condition, each condition gets its own "slope" parameter.

Let $C$ be the set of conditions, $\beta_c$ be the slope parameter for a particular condition $c \in C$, and $\delta(a, b)$ be an indicator function that evaluates to $1$ if $a$ and $b$ are identical and $0$ otherwise. Our linear model can be expressed in two (of many) ways:

1. We do not consider the control condition distinctly from treatment conditions:
    - $\beta_c$ represents the experimental measurement resulting from treatment condition $c$
  $$y = f(x_1) = \sum_{c \in C} \beta_c \delta(c, x_1)$$
2. Consider treatment conditions relative to a control condition (control condition denoted by $c = 0$):
    - $\beta_c$ represents the difference in experimental measurement between treatment condition $c$ and control
  $$y = f(x_1) = \beta_0 + \sum_{c \neq 0} \beta_c \delta(c, x_1)$$

### Interactions and Linearity

Consider two distinct sample-level covariates $x_1$ (e.g., cell line) and $x_2$ (e.g., drug treatment). Then
$$y = f(x_1, x_2) = \beta_0 + x_1 \beta_1 + x_2 \beta_2 + x_1 x_2 \beta_{12}$$

In matrix notation, $y = X \beta$, each row of $y$ and $X$ correspond to a sample and measurement, and $X$ is called the **design matrix**. Here, the columns of $X$ would be
$\begin{bmatrix} 1 & x_1 & x_2 & x_1 x_2 \end{bmatrix}$ and $\beta = \begin{bmatrix} \beta_0 & \beta_1 & \beta_2 & \beta_{12} \end{bmatrix}^\top$ where the first column of $X$ is 1 to account for the intercept $\beta_0$. Least-squares estimation of $\beta$ is then simply $\hat{\beta} = X^\dagger y$.

Notes
- Matrix notation makes it clear that the word "linear" in linear model refers to linearity in $\beta$, not the sample-level covariates, since we can express interactions between sample-level covariates as $x_1 x_2$.
  - The model remains linear in $\beta$ if we scale the counts $y$ according to $\tilde{y} = f(y)$, where $f$ may be a variance stabilizing transform, for example.
- Representing the interaction between two sample-level covariates as their product (e.g., $x_1 x_2$) is only valid if both sample-level covariates are binary indicators. To generalize to multiple possible values for each sample-level covariate, let $C_1$ denote the domain of $x_1$ and $C_2$ denote the domain of $x_2$. Then

$$y = f(x_1, x_2) = \sum_{c \in C_1} \beta_c \delta(c, x_1) + \sum_{c \in C_2} \beta_c \delta(c, x_2) + \sum_{(c_1, c_2) \in C_1 \times C_2} \beta_{c_1,c_2} \delta(c_1, x_1) \delta(c_2, x_2)$$

- Whether to include interactions among sample-level covariates is a modeling choice that depends on the amount of data available. For example, if there are 3 distinct binary covariates, then a **saturated** model would require ${3 \choose 1} + {3 \choose 2} + {3 \choose 3} = 3 + 3 + 1 = 7$ parameters $\beta_1$, $\beta_2$, $\beta_3$, $\beta_{12}$, $\beta_{13}$, $\beta_{23}$, $\beta_{123}$. If there is insufficient data to accurately estimate the effects of all interactions, or there is good reason to assume that the covariates are truly independent, interaction parameters may be dropped.
- In R formulas, interactions are specified using the `:` and `*` operators. From the [documentation for `lm()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html):
  > A typical model has the form response ~ terms where response is the (numeric) response vector and terms is a series of terms which specifies a linear predictor for response. A terms specification of the form first + second indicates all the terms in first together with all the terms in second with duplicates removed. A specification of the form first:second indicates the set of terms obtained by taking the interactions of all terms in first with all terms in second. The specification first\*second indicates the cross of first and second. This is the same as first + second + first:second.

## Debugging

Debugging generic functions: https://stackoverflow.com/questions/1708074/debugging-generic-functions-in-r
`trace("plot", browser, exit=browser, signature = c("track", "missing")) `

# Piping

https://stackoverflow.com/questions/38717657/use-pipe-without-feeding-first-argument
https://cran.r-project.org/web/packages/magrittr/vignettes/magrittr.html

# Package notes

## dplyr

functions within mutate and summarise can return multiple values if they return a data.frame or matrix

## RDAVIDWebService
- Installation
  - https://steinbaugh.com/rdavidwebservice
  - http://johnstantongeddes.org/aptranscriptome/2014/05/21/rDAVIDWebService-install.html
- `connect(david)` refreshes the `david` DAVIDWebService instance, removing all uploaded gene lists.
- Simultaneously running multiple DAVIDWebService instances
  - Summary: each instance stores independent gene lists, but querying simultaneously may cause conflicts
  - New instances of DAVIDWebService (i.e. `david <- DAVIDWebService$new(email = 'email', url = 'url')`), even when created with the same email / URL, are independent and carry their own uploaded gene lists and other information.
  - Querying multiple DAVIDWebService instances simultaneously (e.g. in a parallel foreach loop) may cause errors (from empirical experience), likely due to how RSQLite, a dependency of RDAVIDWebService, temporarily writes tables to files.
- Defaults
  - Functional Annotation Chart: all terms with EASE p-value < 0.1

## pheatmap
- Workaround to add x- and y-axis titles (not natively supported): 

## doParallel

Definitions
- cluster: group of 1+ nodes
- node: computer with 1+ processors
- processor: processing unit with 1+ cores

Packages
- **multicore**: relies on the POSIX `fork` system call. Only runs on 1 node.
- **snow**: manages a cluster of nodes (worker processes) listening via sockets. Can run across multiple nodes.
- **parallel**: merges functionality of **multicore** and **snow** packages
- **doParallel**: interface between **foreach** and **parallel** packages

Backend selected by `registerDoParallel(cl, cores = NULL)`
- Can pass an integer to `cl` argument, and it will figure out the rest
  - Not necessary to pass a cluster object, i.e. `cl = makeCluster(numNodes)`
  - If `cl` is a valid integer or a cluster object, the `cores` argument is ignored.
  - Windows: a cluster object is always created, and parallelization is implemented via the `snow` package
  - Linux
    - If `cl` is a cluster object, `snow` is used as the backend.
    - If `cl` is an integer, `multicore` is used as the backend.
- Summary table: where `m`, `n` are integers, and `mC()` is an abbreviation for `parallel::makeCluster()`

| Environment | `cl`    | `cores` | backend | threads   |
| ----------- | ------- | ------- | ------- | --------- |
| UNIX        | `NULL`  | `NULL`  | MC      | `NULL`    |
| UNIX        | `m`     | `NULL`  | MC      | `m`       |
| UNIX        | `mC(m)` | `NULL`  | SNOW    | `mC(m)`   |
| UNIX        | `NULL`  | `n`     | MC      | `n`       |
| UNIX        | `m`     | `n`     | MC      | `m`       |
| UNIX        | `mC(m)` | `n`     | SNOW    | `mC(m)`   |
| Windows     | `NULL`  | `NULL`  | SNOW    | `mC(3)`   |
| Windows     | `m`     | `NULL`  | SNOW    | `mC(m)`   |
| Windows     | `mC(m)` | `NULL`  | SNOW    | `mC(m)`   |
| Windows     | `NULL`  | `n`     | SNOW    | `mC(n)`   |
| Windows     | `m`     | `n`     | SNOW    | `mC(m)`   |
| Windows     | `mC(m)` | `n`     | SNOW    | `mC(m)`   |

The number of CPUs the current process can use (as opposed to the number of CPUs in the system) can be obtained with `length(parallel::mcaffinity())` (analogous to `len(os.sched_getaffinity(0))` on Python).

References
- Vignettes
  - **parallel**: http://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf
  - **doParallel**: https://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf
- Source
  - `registerDoParallel()`: https://github.com/cran/doParallel/blob/master/R/doParallel.R

## ggplot2

Implicit grouping: categorical variables that map to an aesthetic (x, y, color, shape, fill, etc.) subset the data into groups.
- To override implicit grouping, set `<geom_function>(mapping = aes(group = <constant>)`
- Example:
  ```r
  ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
    geom_point() +                                      # implicit grouping: points are colored by 'drv' group
    geom_smooth(se = FALSE) +                           # implicit grouping: different colored lines for each 'drv' group
    geom_smooth(se = FALSE, mapping = aes(group = 123)) # ungrouped: 1 line over all data points
  ```

Statistical transformations
- Explicity access computed variables (e.g., `..prop..` and `..count..` for `stat_count()`) using extra dots in the variable names

Useful extensions
- Nested facets based on patchwork package: https://coolbutuseless.github.io/2018/10/31/facet_inception/

## Graphics
- Grid graphics
  - [Getting to Know Grid Graphics](https://www.stat.auckland.ac.nz/~paul/useR2015-grid/)

## msa

`msa` is *not* simply a wrapper around original alignment tool binaries (MUSCLE, Clustal Omega, ClustalW). Rather, it extends the original source code, and the custom C++ code is compiled *with* the original source code. Consequently, it is difficult to reproduce alignment results produced by `msa` by passing similar arguments to the original alignment tool binaries.

# Bioconductor

## Infrastructure

### Hierarchy

(virtual) S4Vectors::Vector
- (virtual) S4Vectors::List
  - S4Vectors::Rle
  - S4Vectors::DataFrame
  - (virtual) IRanges::Ranges
    - (virtual) IRanges::IntegerRanges
      - IRanges::IRanges
      - IRanges::Views
    - (virtual) GenomicRanges::GenomicRanges
      - GenomicRanges::GRanges
  - (virtual) IRanges::RangesList
    - (virtual) IRanges::IntegerRangesList
      - IRanges::IRangesList
    - (virtual) GenomicRanges::GenomicRangesList
      - GenomicRanges::GRangesList
  - (virtual) XVector::XVectorList
    - (virtual) Biostrings::XStringSet
      - Biostrings::BStringSet
      - Biostrings::DNAStringSet
      - Biostrings::RNAStringSet
      - Biostrings::AAStringSet
      - (virtual) Biostrings::QualityScaledXStringSet
        - Biostrings::QualityScaledBStringSet
        - Biostrings::QualityScaledDNAStringSet
        - Biostrings::QualityScaledRNAStringSet
        - Biostrings::QualityScaledAAStringSet
      - (virtual) Biostrings::XStringQuality
        - Biostrings::PhredQuality
        - Biostrings::SolexaQuality
        - Biostrings::IlluminaQuality

Properties of S4Vectors::List
- Single-bracket subsetting: `[`
  - Example: Consider an XStringSet (`testSeqs`), IRanges (`ir`), and GRanges (`gr`)
    ```{r}
    testSeqs <- BStringSet(c("abcdefgh", "ijklmnop", "q", "r", "s", "t"))
    names(testSeqs) <- c("seq1", "seq2", "seq3", "seq4", "seq5", "seq6")

    ir <- IRanges(start = c(1, 4, 6), width = c(2, 1, 1))
    gr <- GRanges(seqnames = c("seq1", "seq2", "seq2"), ranges = ir)

    testSeqs[ir]
    testSeqs[gr]
    ```
    - Subset XStringSet by IRanges --> XStringSet of length `sum(width(ir))`
      - Subset XStringSet by indexes within IRanges
    - Subset XStringSet by GRanges --> XStringSet of length `length(gr)`
      - Element-wise subsetting: each element is a string from the corresponding `seqnames` sequence subset by the corresponding start-end range.
      - Requires that the XStringSet has `names` attribute.
- Looping
  - `aggregate()`: combine sequence extraction with `sapply`
  - `endoapply()`: endomorphic equivalent of `lapply`, i.e., it returns a `S4Vectors::List` derivative of the same class as the input rather than a `base::list` object.
- Annotations
  - Metadata about the object as a whole
    - Representation: `base::list`
    - Accessor: `metadata()`
  - Metadata about the individual elements of the object
    - Representation: `S4Vectors::DataFrame`
    - Accessor: `mcols()` 

Ranges and RangesList methods
- Accessors: `start`, `end`, `width`
- Coercion
  - `as.data.frame([RangesList])`
  - `as(from, "IRanges")`
- Vector operations: 
- Range-based operations
  - Intra-range transformations: transform each range individually
    - `shift`, `narrow`, `resize`, `flank`, `promoters`, `reflect`, `restrict`
  - Inter-range transformations: transform all the ranges together as a set to produce a new set of ranges
    - `range`, `reduce`, `gaps`, `disjoin`, `disjointBins`
  - Set operations: `union`, `intersect`, `setdiff`
  - Coverage and slicing: `coverage`, `slice`
  - Overlaps: `findOverlaps`, `countOverlaps`
- [RangesList] List operations: `elementNROWS`, `unlist`, `relist`, `endoapply`
  - `unlist(rList)` is equivalent to `c(rList[[1]], rlist[[2]], ...)`
  - `relist(data, template)` returns a list-like object with the same "shape" as `template`, filled by `data`

## GenomicRanges

How-To
- Saving/Importing `GRanges` object as/to CSV:
  - Converting to data.frame: `as.data.frame(<GRanges object>)`
    - Loses any `seqinfo`
  - Converting to GRanges
    - data.frame: `as(<data.frame object>, "GRanges")`
    - DataFrame: `makeGRangesFromDataFrame(df, ...)`
- Changing the number of rows of a `GRanges` object displayed via `print()` or `show()`
  ```{r}
  options("showHeadLines" = <value>)
  options("showTailLines" = <value>)
  ```


# FAQ

## Miscellaneous
- Help documentation for special binary operators: `?"%op%"` or `help("%op%")`
- Tools for S4 classes
  - `showClass("class")`: information about a class definition, including inheritance hierarchy
  - `showMethods("class")`: show all methods
  - `class?<class_name>` or `` ?`<class_name>-class` ``: access help documentation about a class
- Comparisons
  - `if` statements: use `identical()` instead of `==` or `!=`, which may return `NA` values
  - Numerical and complex values: `identical(all.equal(x,y), TRUE)`
  - See `?Comparison` or https://stat.ethz.ch/R-manual/R-devel/library/base/html/Comparison.html

These operators are sometimes called as functions as e.g. `<(x, y)`: see the description of how argument-matching is done in Ops. 

## Efficient code
Code profiling
  - Base R: `system.time({code_block})`
  - Packages: microbenchmark, profvis, lineprof, etc. See http://adv-r.had.co.nz/Profiling.html.

Specific examples
- Accessing single element in a data frame or tibble

    | Rank | Method                                    | `class(r)` | `class(c)`           |
    | ---- | ----------------------------------------- | -----------| -------------------- |
    | 1    | `df[[c]][r]`                              | integer    | integer or character |
    | 2    | `df[r,c]`                                 | integer    | integer              |
    | 3    | `df[r,][[c]]`                             | integer    | integer              |
    | 4    | `df[[c]][r]`                              | logical    | integer or character |
    | 5    | `df[r,c]`                                 | logical    | logical              |
    | 6    | `df %>% filter(r) %>% dplyr::select(!!c)` | logical    | character            |
    | 7    | `subset(df, r, c)`                        | logical    | character or logical |

- Converting string to vector of characters
  1. `strsplit(string, "")[[1]]`
  2. `scan(text = gsub("(.)", "\\1 ", string), what = character())`
  3. `substring(string, 1:nchar(string), 1:nchar(string))`

## Non-standard evaluation (NSE)
Guides / tutorials
- [tidyverse: Programming with dplyr](https://dplyr.tidyverse.org/articles/programming.html)
- [rlang GitHub Issue: Converting string to quosure](https://github.com/r-lib/rlang/issues/116)
- [DataCamp: Formulas in R](https://www.datacamp.com/community/tutorials/r-formula-tutorial)
- [Blog: tidy_eval and base R](https://edwinth.github.io/blog/nse/)

Specific questions
- `tidyr::gather()`: `key` and `value` arguments
  - Make sure tidyr is updated to >= 0.7.0 - see [tidyr 0.7.0 release article](https://www.tidyverse.org/articles/2017/08/tidyr-0.7.0/)
  - Option 1: expression - `gather(data, key = someKey, value = someValue, ...)`
    - The names of the new key and value columns become "someKey" and "someValue".
  - Option 2: unquoted characters - `gather(data, key = "someKey", value = "someValue", ...)`
    - The names of the new key and value columns become "someKey" and "someValue".
  - Option 3: contextual object - `gather(data, key = !!someKey, value = !!someValue, ...)` where `someKey` and `someValue` are [contextual objects](https://tidyr.tidyverse.org/reference/gather.html#rules-for-selection) in the same environment.
  - Option 4 (deprecated): use the standard evaluation form - `tidyr::gather_()`
    - See [tidyr reference](https://tidyr.tidyverse.org/reference/deprecated-se.html) and [SO post](https://stackoverflow.com/questions/37756014/pass-variable-to-tidyrs-gather-to-rename-key-value-columns)
- `tidyselect`-based variable selection (e.g. `dplyr::select()`, `tidyr::gather()`, ...)
  - Exclude contextual objects using `-as.name(contextualObjectName)`
  - See ["SO: Remove columns the tidyeval way"](https://stackoverflow.com/questions/45100518/remove-columns-the-tidyeval-way)

## Graphics

Specific plots
- Dendrograms and heatmaps
  - [Joining a dendrogram and a heatmap](https://stackoverflow.com/questions/42047896/joining-a-dendrogram-and-a-heatmap/42596935): ggdenro for creating the dendrogram, ggplot2 for creating the heatmap, cowplot for arranging plots
  - [Clusters and Heatmaps](https://jcoliver.github.io/learn-r/008-ggplot-dendrograms-and-heatmaps.html): ggdenro for creating the dendrogram, ggplot2 for creating the heatmap, grid for arranging plots

# References

Data Science
- [Hadley Wickham - R for Data Science](http://r4ds.had.co.nz/)
- Data visualization
  - [Stanford Data Challenge Lab - Data Visualization](https://dcl-data-vis.stanford.edu/)

Manuals
- [CRAN R Manuals: An Introduction to R](https://cran.r-project.org/doc/manuals/r-release/R-intro.html)
- [Hadley Wickham - Advanced R](https://adv-r.hadley.nz/)
- [Hadley Wickham - R packages](http://r-pkgs.had.co.nz/)
- [Cookbook for R](http://www.cookbook-r.com/)

Courses
- [Tidyverse-suggested university courses](https://www.tidyverse.org/learn/#university-courses)
  - [Stanford Data Challenge Lab](https://dcl-2017-04.github.io/curriculum/)
- [Stanford STATS 101: Data Science 101](http://web.stanford.edu/class/stats101/)
- [Stanford STATS/CME 195: Introduction to R](http://web.stanford.edu/~msesia/stats195/)

Style
- [The tidyverse style guide](https://style.tidyverse.org/)
- [Google's R Style Guide](https://google.github.io/styleguide/Rguide.xml)

# Installing R and Packages

Errors
- `Error in if (nzchar(SHLIB_LIBADD)) SHLIB_LIBADD else character()`
  - Problem: empty Makeconf file in ~/miniconda3/envs/<env>/lib/R/etc
  - Solution: copy a Makeconf file from a non-conda installation and edit as necessary
  - See https://stackoverflow.com/questions/53813323/installing-r-packages-in-macos-mojave-error-in-if-nzcharshlib-libadd
- `cannot move '<path_to_R>/lib/R/library/00LOCK-<pkg>/00new/<pkg>' ...`
  - Solutions
    1. From the terminal: `R CMD INSTALL --no-lock <pkg>` ([source](https://stackoverflow.com/a/14389028))
    2. From the R interpreter: add `INSTALL_opts = '--no-lock'` as an argument to `install.packages()` (or `BiocManager::install()`) ([source](https://stackoverflow.com/a/14389028))
    3. Disable staged installation by setting the environment variable `R_INSTALL_STAGED=false` ([source](https://github.com/r-lib/ps/issues/63))

Upgrading
- Windows: see [R Windows FAQ](https://cran.r-project.org/bin/windows/base/rw-FAQ.html#What_0027s-the-best-way-to-upgrade_003f)
  1. Uninstall previous version of R
  2. Copy packages from the old library folder into the new library folder.
  3. Run `update.packages(checkBuilt = TRUE)`

Installing binary packages from Posit Package Manager (PPM)
- Change `repos` option to PPM: see https://packagemanager.posit.co/client/#/
- Example (Caltech HPC, running RHEL 9): add the following to `~/.Rprofile`:
    ```{r}
    options(
      HTTPUserAgent = sprintf(
          "R/%s R (%s)",
          getRversion(),
          paste(
              getRversion(),
              R.version["platform"],
              R.version["arch"],
              R.version["os"]
          )
      ),
      repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/rhel9/latest"),
      BioC_mirror = "https://packagemanager.posit.co/bioconductor",
      BIOCONDUCTOR_CONFIG_FILE = "https://packagemanager.posit.co/bioconductor/config.yaml"
    )
    ```
- Reference: https://www.r-bloggers.com/2023/07/posit-package-manager-for-linux-r-binaries/

## WSL

### Upgrading R
- https://stackoverflow.com/questions/46214061/how-to-upgrade-r-in-linux
- http://bioinfo.umassmed.edu/bootstrappers/bootstrappers-courses/courses/rCourse/Additional_Resources/Updating_R.html

### References
- https://github.com/anilchalisey/parseR/wiki/Setting-up-WSL-Bash-on-Windows-10#installing-r-and-rstudio
- https://cloud.r-project.org/bin/linux/ubuntu/

## Windows

Rtools: https://cran.r-project.org/bin/windows/Rtools/

## Linux

If installed in a `conda` environment, it may cause the `pager` command to behave unexpectedly.
- Background
  - By default, `pager` just redirects to `less`: `/usr/bin/pager -> /etc/alternatives/pager -> /bin/less`
  - `pager` is used by utilities such as `man`
    - `man` takes an option `-P pager` that specifies a pager to use, which defaults to `$MANPAGER`, `$PAGER`, or `cat` (in that order)
- Problem: Installing R and related packages adds `pager -> ../lib/R/bin/pager` to `<conda_install_dir>/envs/<env_name>/bin/`. Activating `env_name` adds `<conda_install_dir>/envs/<env_name>/bin/` to `$PATH`, redirecting `pager` to `<conda_install_dir>/envs/<env_name>/lib/R/bin/pager` instead of `less`.
  - `../lib/R/bin/pager` is a super short shell script that executes `$PAGER` with any arguments passed
    - Unclear what its purpose is. The comments in the script indicate that `$PAGER` is determined at configure time and recorded in `<conda_install_dir>/envs/<env_name>/etc/Renviron`, but `etc/Renviron` does not necessarily exist.
      - The Renviron file is used to store system variables, such as the the `R_LIBS` path: `R_LIBS=~/R/library`. See https://csgillespie.github.io/efficientR/3-3-r-startup.html#renviron or https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html.
  - It is still unclear which conda package (whether R itself or an R package, such as r-tidyverse) introduces this issue.
- Workarounds
  - `man`-specific
    - Specify the `-P pager` option each time you use `man`
    - Set `$MANPAGER` upon activation of the environment. See https://conda.io/docs/user-guide/tasks/manage-environments.html#saving-environment-variables
  - generic, may affect R behavior
    - Set `$PAGER` upon activation of the environment. See https://conda.io/docs/user-guide/tasks/manage-environments.html#saving-environment-variables
    - Remove the new `pager` script installed by conda: `rm <conda_install_dir>/envs/<env_name>/bin/pager`

## RStudio

Using an installation R at a non-conventional path
- RStudio expects R to be installed at certain locations, and newer versions may simply refuse to launch if it cannot find an R installation. To use R installed at a non-conventional path, edit `C:\Users\<username>\AppData\Roaming\RStudio\config.json`:
  ```{json}
  "platform": {
    "windows": {
        "rBinDir": "<path to R bin/x64 folder>",
        "preferR64": true,
        "rExecutablePath": "<path to R bin/x64 folder>R.exe"
    }
  }
  ```
  Source: https://github.com/rstudio/rstudio/issues/11141#issuecomment-1212085629