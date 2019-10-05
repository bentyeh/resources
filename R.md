- [Package notes](#Package-notes)
  - [RDAVIDWebService](#RDAVIDWebService)
  - [pheatmap](#pheatmap)
  - [doParallel](#doParallel)
  - [ggplot2](#ggplot2)
  - [Graphics](#Graphics)
  - [msa](#msa)
- [Bioconductor](#Bioconductor)
  - [Infrastructure](#Infrastructure)
    - [Hierarchy](#Hierarchy)
  - [GenomicRanges](#GenomicRanges)
- [FAQ](#FAQ)
  - [Miscellaneous](#Miscellaneous)
  - [Efficient code](#Efficient-code)
  - [Non-standard evaluation (NSE)](#Non-standard-evaluation-NSE)
  - [Graphics](#Graphics-1)
- [References](#References)
- [Installing R](#Installing-R)
  - [WSL](#WSL)
    - [Upgrading R](#Upgrading-R)
    - [References](#References-1)
  - [Windows](#Windows)
  - [Linux](#Linux)

# Package notes

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
- Explicity access computed variables (e.g., `..prop..` and `..count..` for `stat_count()`) using  extra dots in the variable names

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
  - `endoapply()`: endomorphic equivalent of `lapply`, i.e., i.e. it returns a `S4Vectors::List` derivative of the same class as the input rather than a `base::list` object.
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

# Installing R

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