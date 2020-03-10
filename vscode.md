# Settings
The Settings Editor can be invoked by launching the Command Palette (`Ctrl` + `P`) &rightarrow; `Preferences: Open Settings (UI)`.

Types of settings
- [User Settings](https://code.visualstudio.com/docs/getstarted/settings): \<path_to_VSCode\>\data\user-data\User\settings.json
  - Scope: Global - any instance of VSCode
  - Most extensions will add settings here
- [Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings): \<path_to_workspace_directory\>\\<workspace-name\>.code-workspace
  - Scope: Workspace - only when the workspace is open
- [Folder Settings](https://code.visualstudio.com/docs/editor/multi-root-workspaces#_settings): \<path_to_folder\>\.vscode\settings.json
  - Scope: Folder - only files within the folder
- Settings apply by precedence. Adding to User/Workspace/Folder Settings masks any [default settings](https://code.visualstudio.com/docs/getstarted/settings#_default-settings) without overwriting them.
  - Currently, there does not appear to be a means of appending to default settings; any changes *overwrite* default settings [(source)](https://stackoverflow.com/questions/57796423/how-do-i-append-a-setting-to-the-defaults-in-visual-studio-code)
- Quickly check which settings have been modified from default by opening the Settings Editor and typing `@modified` into the search box.

Suggestions
- Multiple projects in workspace
  - Background: A "root" folder is any folder added to a workspace via File > Add Folder to Workspace or specifying folders in the Workspace Settings file.
  - Problem: By default, the terminal working directory will be set to the root folder of whichever file is currently being edited or the first folder (alphabetically) in the workspace.
    - Example 1: Opening an instance of the integrated terminal
    - Example 2: Any code run via the Debugger (e.g., `F5` or `Ctrl-F5`) or right-clicking a file and selecting "Run \<language\> File in Terminal"
  - Solution
    - Multi-root workspaces
      - Individually add "root" project folders to workspace
      - Paths for code within each folder may be relative to the root folder.
    - Modify workspace launch configurations so that code is executed from the file directory.
      - Example: add to workspace settings:
        ```{json}
        "launch": {
          "configurations": [
            {
              "name": "Python: Current File (Integrated Terminal)",
              "type": "python",
              "request": "launch",
              "program": "${file}",
              "console": "integratedTerminal",
              "cwd": "${fileDirname}" # <-- add this line
            }
          ]
        }
        ```
- Set different conda Python environments for workspaces
  - Add the following to Workspace Settings (note the double backslashes for Windows paths):
    ```{json}
    "settings": {
      "python.pythonPath": "<path_to_conda_installation>\\envs\\<env_name>\\python.exe"
    }
    ```

# Extensions

## LaTeX

Setup LaTeX with Visual Studio Code and MikTeX on Windows
- Install LaTeX Workshop extension
  - Enable synctex support: [download](https://github.com/aminophen/w32tex-build) `synctex.exe` and `kpathsea623.dll` to MikTeX `bin\` directory (e.g., D:\Software\PortableApps\MiKTeX\texmfs\install\miktex\bin).
- Add recipe for `latexmk` and/or `pdflatex` with `-shell-escape` (`-enable-write18`) option
  - `latexmk` requires a Perl installation (i.e., `perl` is avaiable from `%PATH%`)
  - Add the following to User Settings (in addition to existing default values). Note that the default keybinding `Ctrl + Alt + B` for "Build LaTeX Project" will use the first recipe under `latex-workshop.latex.recipes`.
    ```{json}
    "latex-workshop.latex.recipes": [
      {
        "name": "latexmk (shell escape)",
        "tools": [
          "latexmk"
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
        "name": "latexmk_shell_escape",
        "command": "latexmk",
        "args": [
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
                  "-pdf",
                  "-shell-escape",
          "-outdir=%OUTDIR%",
          "%DOC%"
        ],
        "env": {}
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
        ],
        "env": {}
      }
    ]
    ```

## Markdown

VS Code has a built-in Markdown previewer, but it does not natively support LaTeX. Markdown All in One is generally sufficient for displaying LaTeX equations and exporting the document to HTML. For finer control of LaTeX in Markdown, consider the Markdown+Math extension. Both rely on KaTeX for typesetting.

## Python

