# Resources

# C++
General documentation
- C++ Standard Library header files (and comparison to C Standard Library header files): http://en.cppreference.com/w/cpp/header

Specific questions
- const keyword
  - https://stackoverflow.com/questions/3141087/what-is-meant-with-const-at-end-of-function-declaration
  - https://stackoverflow.com/questions/751681/meaning-of-const-last-in-a-c-method-declaration
- printing pointer values (hex) to stdout: https://stackoverflow.com/questions/11095653/printing-hexadecimal-values-to-console-in-c

# R

## Tutorials
Base R
- [CRAN R Manuals: An Introduction to R](https://cran.r-project.org/doc/manuals/r-release/R-intro.html)
- [Hadley Wickham - R for Data Science](http://r4ds.had.co.nz/)
- [Hadley Wickham - Advanced R](https://adv-r.hadley.nz/)
- [Hadley Wickham - R packages](http://r-pkgs.had.co.nz/)
- [Cookbook for R](http://www.cookbook-r.com/)

Packages
- [cowplot](https://cran.r-project.org/web/packages/cowplot/vignettes/introduction.html)

## Style
- [Google Style Guide](https://google.github.io/styleguide/Rguide.xml)

## Package notes
RDAVIDWebService
- Installation - see R_installation.md
- `connect(david)` refreshes the `david` DAVIDWebService instance, removing all uploaded gene lists.
- Simultaneously running multiple DAVIDWebService instances
  - Summary: each instance stores independent gene lists, but querying simultaneously may cause conflicts
  - New instances of DAVIDWebService (i.e. `david <- DAVIDWebService$new(email = 'email', url = 'url')`), even when created with the same email / URL, are independent and carry their own uploaded gene lists and other information.
  - Querying multiple DAVIDWebService instances simultaneously (e.g. in a parallel foreach loop) may cause errors (from empirical experience), likely due to how RSQLite, a dependency of RDAVIDWebService, temporarily writes tables to files.
- Defaults
  - Functional Annotation Chart: all terms with EASE p-value < 0.1

pheatmap
- Workaround to add x- and y-axis titles (not natively supported): 

doParallel
- `registerDoParallel(cl, cores = NULL)`
  - Can pass an integer to `cl` argument, and it will figure out the rest
    - Not necessary to pass a cluster object, i.e. `cl = makeCluster(numNodes)`
    - If `cl` is a valid integer or a cluster object, the `cores` argument is ignored.
  - Windows: a cluster object is always created, and parallelization is implemented via the `snow` package
  - Linux
    - If `cl` is a cluster object, `snow` is used as the backend.
    - If `cl` is an integer, `multicore` is used as the backend.
  - Reference: [source code](https://github.com/cran/doParallel/blob/master/R/doParallel.R)

## Graphics
- Grid graphics
  - [Getting to Know Grid Graphics](https://www.stat.auckland.ac.nz/~paul/useR2015-grid/)

## How-tos
- Non-standard evaluation (NSE)
  - Guides / tutorials
    - [tidyverse: Programming with dplyr](https://dplyr.tidyverse.org/articles/programming.html)
    - [rlang GitHub Issue: Converting string to quosure](https://github.com/r-lib/rlang/issues/116)
    - [DataCamp: Formulas in R](https://www.datacamp.com/community/tutorials/r-formula-tutorial)
    - [Blog: tidy_eval and base R](https://edwinth.github.io/blog/nse/)
  - Specific questions
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
- Graphics
  - Dendrograms and heatmaps
    - [Joining a dendrogram and a heatmap](https://stackoverflow.com/questions/42047896/joining-a-dendrogram-and-a-heatmap/42596935)
      - ggdenro for creating the dendrogram, ggplot2 for creating the heatmap, cowplot for arranging plots
    - [Clusters and Heatmaps](https://jcoliver.github.io/learn-r/008-ggplot-dendrograms-and-heatmaps.html)
      - ggdenro for creating the dendrogram, ggplot2 for creating the heatmap, grid for arranging plots

## Classes
- [Tidyverse-suggested university courses](https://www.tidyverse.org/learn/#university-courses)
  - [Stanford Data Challenge Lab](https://dcl-2017-04.github.io/curriculum/)
- [Stanford STATS 101: Data Science 101](http://web.stanford.edu/class/stats101/)
- [Stanford STATS/CME 195: Introduction to R](http://web.stanford.edu/~msesia/stats195/)


# Markdown
General documentation
- GitHub Flavored Markdown Spec: https://github.github.com/gfm/
- GitHub Mastering Markdown: https://guides.github.com/features/mastering-markdown/
- Adam Pritchard Markdown Cheatsheat: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

# LaTeX
General documentation
- LaTeX Wikibooks: https://en.wikibooks.org/wiki/LaTeX
- ShareLaTeX Documentation: https://www.sharelatex.com/learn/Main_Page

Specific questions
- Number quote environment like an equation: https://tex.stackexchange.com/questions/204091/number-quote-environment-like-an-equation
- One label for an aligned set of equations using `\begin{aligned}`: https://tex.stackexchange.com/questions/95402/what-is-the-difference-between-aligned-in-displayed-mode-and-starred-align