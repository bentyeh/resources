# LaTeX
General documentation
- LaTeX Wikibooks: https://en.wikibooks.org/wiki/LaTeX
- Overleaf Documentation: https://www.overleaf.com/learn/latex/Main_Page

Compiling
- `pdflatex [filename].tex` &rightarrow; [filename].pdf
  - Common options: `-synctex=1 -interaction=nonstopmode -quiet`
  - `-shell-escape` (or equivalently, `-enable-write18`)
    - Enables `write18{shell command}` to run external system commands from inside a LaTeX file, e.g., as used by the `minted` package (code formatting and highlighting).
    - This can be a security vulnerability, hence why it is not enabled by default.
    - More info: [here](http://joshua.smcvt.edu/latex2e/Command-line-options.html), [here](https://tex.stackexchange.com/questions/88740/what-does-shell-escape-do), and [here](https://tex.stackexchange.com/questions/375583/where-should-i-put-pdflatex-shell-escape-tex-file-code).
- `latexmk [filename].tex` &rightarrow; [filename].[depends]
  - > A Perl script for running LaTeX the correct number of times to resolve cross references, etc; it also runs auxiliary programs (bibtex, makeindex if necessary, and dvips and/or a previewer as requested) [(source)](http://personal.psu.edu/~jcc8/software/latexmk/)
  - Common options: `-pdf -synctex=1 -interaction=nonstopmode -quiet`
  - [Good 3rd-party tutorial](https://mg.readthedocs.io/latexmk.html)
  - Requires a Perl installation (i.e., `perl` must be found in `%PATH%`)
    - [Strawberry Perl](http://strawberryperl.com/) is a [recommended](https://www.perl.org/get.html#win32) portable binary distribution for Windows.
- `latex [filename].tex` &rightarrow; [filename].dvi
- `dvips -o [filename].ps [filename].dvi` &rightarrow; [filename].ps
- `dvipdfm [filename].dvi` &rightarrow; [filename].pdf
  - Creating a DVI file using `latex` and then converting to PDF produces PostScript images, while the `pdflatex` produces PDF or JPG images. [(source)](https://guides.lib.wayne.edu/latex/compiling)

Specific questions
- Number quote environment like an equation: https://tex.stackexchange.com/questions/204091/number-quote-environment-like-an-equation
- One label for an aligned set of equations using `\begin{aligned}`: https://tex.stackexchange.com/questions/95402/what-is-the-difference-between-aligned-in-displayed-mode-and-starred-align. Also see https://en.wikibooks.org/wiki/LaTeX/Advanced_Mathematics#Other_environments.
