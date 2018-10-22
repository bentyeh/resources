# Resources

# C++
General documentation
- C++ Standard Library header files (and comparison to C Standard Library header files): http://en.cppreference.com/w/cpp/header

Specific questions
- const keyword
  - https://stackoverflow.com/questions/3141087/what-is-meant-with-const-at-end-of-function-declaration
  - https://stackoverflow.com/questions/751681/meaning-of-const-last-in-a-c-method-declaration
- printing pointer values (hex) to stdout: https://stackoverflow.com/questions/11095653/printing-hexadecimal-values-to-console-in-c

# Markdown
General documentation
- GitHub Flavored Markdown Spec: https://github.github.com/gfm/
- GitHub Mastering Markdown: https://guides.github.com/features/mastering-markdown/
- Adam Pritchard Markdown Cheatsheat: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

# LaTeX
General documentation
- LaTeX Wikibooks: https://en.wikibooks.org/wiki/LaTeX
- Overleaf Documentation: https://www.overleaf.com/learn/latex/Main_Page

Compiling
- `latex [filename].tex` &rightarrow; [filename].dvi
- `pdflatex [filename].tex` &rightarrow; [filename].pdf
  - Common options: `-synctex=1 -interaction=nonstopmode -quiet`
- `dvips -o [filename].ps [filename].dvi` &rightarrow; [filename].ps
- `dvipdfm [filename].dvi` &rightarrow; [filename].pdf
  - Creating a DVI file using the latex command and then converting to PDF produces PostScript images, while the `pdflatex` produces PDF or JPG images. [(source)](https://guides.lib.wayne.edu/latex/compiling)

Specific questions
- Number quote environment like an equation: https://tex.stackexchange.com/questions/204091/number-quote-environment-like-an-equation
- One label for an aligned set of equations using `\begin{aligned}`: https://tex.stackexchange.com/questions/95402/what-is-the-difference-between-aligned-in-displayed-mode-and-starred-align. Also see https://en.wikibooks.org/wiki/LaTeX/Advanced_Mathematics#Other_environments.
- Invoke LaTeX with `-shell-escape` flag
  - pdflatex: add the `-enable-write18` option
    - This is necessary for TeXMaker (Windows) to compile documents using the `minted` package
    - https://tex.stackexchange.com/questions/375583/where-should-i-put-pdflatex-shell-escape-tex-file-code

