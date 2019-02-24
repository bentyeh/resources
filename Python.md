# Packages

## Numpy

NumPy array broadcasting tutorial: https://jakevdp.github.io/PythonDataScienceHandbook/02.05-computation-on-arrays-broadcasting.html

# Environments

## Jupyter Notebooks

### Installing multiple kernels

Notes
- IPython 5.x is the last version of IPython to support Python 2.

References
- https://ipython.readthedocs.io/en/latest/install/kernel_install.html

**Option 1: Use `ipykernel install` command**

This assumes you have 2 environments: one that includes jupyter, and the other than includes a kernel you want to use with jupyter.

From the kernel's environment, run the following command: `[path_to_kernel_env]/bin/python -m ipykernel install --prefix=[path_to_jupyter_env] --name 'python[version]' --display-name 'Python [version]`

The `--name` argument specifies the name of the newly created configuration subdirectory under the jupyter kernels folder described below. The `--display-name` argument just sets the value of the `display_name` key in the kernelspec.

**Option 2: Create new kernel spec**

The `kernels/` folder will be under one of the "data" paths indicated by `jupyter --paths`. For jupyter installed in a conda environment, it can be found at [path_to_conda_installation]/[env_name]/share/jupyter/kernels.

Each subdirectory under `.../kernels/` represents the configuration of a particular kernel. For example, there can be separate `.../kernels/python2` and `.../kernels/python3` subdirectories representing separate Python 2 and 3 configurations. Usually, this configuration consists of 3 files:
1. kernel.json - [kernelspec](https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernelspecs)
   - `argv` key: actual command line arguments (e.g., path to Python executable) used to start the kernel
   - `display_name`: kernel name as displayed in the jupyter notebook UI
   - `language`: name of the language of the kernel
2. logo-32x32.png - logo of the kernel (e.g., the Python logo or R logo)
3. logo-64x64.png - logo of the kernel (e.g., the Python logo or R logo)

An easy way to create a configuration is to copy an existing configuration and modify appropriately.

### NBConvert

Reference: https://nbconvert.readthedocs.io/

#### Hiding cells from output

Add a tag (e.g. "hide_cell") to the metadata of cells to hide.
1. [Option 1]: Add a "tags" list to the cell metadata. For example, 
```json
{
  "cell_type" : "markdown",
  "metadata" : {
    "tags": ["hide_cell"]
  },
  "source" : "This is a cell",
}
```
2. [Option 2]: Via jupyter notebook
   - With the notebook opened in the Jupyter Notebook interface, click View > Cell Toolbar > Tags
   - Add tag to desired cells

Run the `jupyter nbconvert` command with the argument `--TagRemovePreprocessor.remove_cell_tags="['<tag>']"`. For example,
`jupyter nbconvert example.ipynb --TagRemovePreprocessor.remove_cell_tags="['hide_cell']"`

Notes
- I currently do not know of any way to add such tags through Google Colab.

Reference: https://stackoverflow.com/questions/31517194/how-to-hide-one-specific-cell-input-or-output-in-ipython-notebook

#### Saving to PDF

Prequisites
- xelatex: install on Ubuntu via `sudo apt-get install texlive-xetex`
  - The `texlive-core` package in the conda-forge repository (https://anaconda.org/conda-forge/texlive-core) does not seem to install the xelatex executable.
- pandoc

LaTeX (and PDF) restrictions
- Single dollar signs for LaTeX cannot be followed by whitespace
- Inserting images
  - HTML tags `<img src=[url] width=[width]>` can be hit-or-miss.
  - Markdown syntax, especially if referenced as a Google Drive file id (e.g., `![markdown_image](https://drive.google.com/thumbnail?id=1K6Sd3v3nFz5zyTANFGt7RkUUM7aXpW7w&sz=h301)`), may not be converted properly due to improperly escaped symbols.
- Use 4 spaces for list indents
- Lists need to start after a newline

Directories and intermediary files
- Background: any figures produced by running the Jupyter notebook (e.g., any `matplotlib` figure) will be saved first as intermediate PNG files referenced by the intermediate LaTeX file
- If the path of the file to be converted is passed as an absolute path, then the LaTeX file will have absolute paths to the intermediate PNG files
  - Unfortunately, if the absolute path contains spaces (which is likely if using Google Colab, since the path to a file will almost always go through the directory '/content/gdrive/My Drive'), the LaTeX file will have an invalid `\includegraphics{<path with spaces>}` command.
  - The solution is to set the working directory to the directory containing the Jupyter notebook to be converted, then use relative paths.
