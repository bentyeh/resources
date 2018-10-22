Setup LaTeX with Visual Studio Code and MikTeX on Windows
- Install LaTeX Workshop extension
  - Enable synctex support: [download](https://github.com/aminophen/w32tex-build) synctex.exe and kpathsea623.dll to MikTeX `bin\` directory (e.g., D:\Software\PortableApps\MiKTeX\texmfs\install\miktex\bin).
- Add recipe for `pdflatex` with `-shell-escape` (`-enable-write18`) option:

    ```{json}
    "latex-workshop.latex.recipes": [
      {
        "name": "latexmk",
        "tools": [
          "latexmk"
        ]
      },
      {
        "name": "pdflatex -> bibtex -> pdflatex*2",
        "tools": [
          "pdflatex",
          "bibtex",
          "pdflatex",
          "pdflatex"
        ]
      },
      {
        "name": "pdflatex_shell_escape * 3",
        "tools": [
          "pdflatex_shell_escape",
          "pdflatex_shell_escape",
          "pdflatex_shell_escape"
        ]
      }
    ],
    "latex-workshop.latex.tools": [
      {
        "name": "latexmk",
        "command": "latexmk",
        "args": [
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
          "-pdf",
          "%DOC%"
        ]
      },
      {
        "name": "pdflatex",
        "command": "pdflatex",
        "args": [
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
          "%DOC%"
        ]
      },
      {
        "name": "bibtex",
        "command": "bibtex",
        "args": [
          "%DOCFILE%"
        ]
      },
      {
        "name": "pdflatex_shell_escape",
        "command": "pdflatex",
        "args": [
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
          "-enable-write18",
          "%DOC%"
        ]
      }
    ]
    ```