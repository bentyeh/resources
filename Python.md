# Python Notes
- [Python Notes](#python-notes)
- [Base Python](#base-python)
    - [Two ways to call a method](#two-ways-to-call-a-method)
- [Packages](#packages)
  - [Numpy](#numpy)
  - [Jupyter Notebooks](#jupyter-notebooks)
    - [Installing multiple kernels](#installing-multiple-kernels)
      - [Option 1: `nb_conda_kernels` package](#option-1-nbcondakernels-package)
      - [Option 2: Use `ipykernel install` command](#option-2-use-ipykernel-install-command)
      - [Option 3: Create new kernel spec](#option-3-create-new-kernel-spec)
    - [NBConvert](#nbconvert)
      - [Hiding cells from output](#hiding-cells-from-output)
      - [Saving to PDF](#saving-to-pdf)
- [Miscellaneous](#miscellaneous)
  - [Loading compressed TIFF images](#loading-compressed-tiff-images)

# Base Python

### Two ways to call a method

Let `obj = myClass()` be an instance of a `myClass` object, which defines a `myMethod()` method. Then the following statements are equivalent:
1. `obj.myMethod()`
2. `myClass.myMethod(obj)`
   - This statement makes it clear that `obj` is passed into the method as the `self` argument.

# Packages

## Numpy

NumPy array broadcasting tutorial: https://jakevdp.github.io/PythonDataScienceHandbook/02.05-computation-on-arrays-broadcasting.html

## Jupyter Notebooks

### Installing multiple kernels

Notes
- IPython 5.x is the last version of IPython to support Python 2.

References
- https://ipython.readthedocs.io/en/latest/install/kernel_install.html
- https://docs.anaconda.org/anaconda/user-guide/tasks/use-jupyter-notebook-extensions/

#### Option 1: `nb_conda_kernels` package

Assumptions / requirements:
- You use `conda` to manage Python environments.
- Different desired kernels are installed in different environments.

Install the `nb_conda_kernels` package. This enables the following features:
1. Creating a notebook from the Files tab: you can pick any kernel in any of your environments in which to create the new notebook.
2. Within a running notebook: from the Kernel tab, you can change the kernel of the running notebook to any kernel in any of your environments.

#### Option 2: Use `ipykernel install` command

This assumes you have 2 environments: one that includes jupyter, and the other than includes a kernel you want to use with jupyter.

From the kernel's environment, run the following command: `[path_to_kernel_env]/bin/python -m ipykernel install --prefix=[path_to_jupyter_env] --name 'python[version]' --display-name 'Python [version]`

The `--name` argument specifies the name of the newly created configuration subdirectory under the jupyter kernels folder described below. The `--display-name` argument just sets the value of the `display_name` key in the kernelspec.

#### Option 3: Create new kernel spec

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

# Miscellaneous

## Loading compressed TIFF images

Matplotlib depends on Pillow for reading all image files beyond PNGs ([see `matplotlib.pyplot.imread` documentation](https://matplotlib.org/api/_as_gen/matplotlib.pyplot.imread.html)). Pillow can read and write uncompressed TIFF files natively but depends on libtiff for compressed TIFF files.

libtiff can fail to read some compressed TIFF files, such as those generated by Leica Application Suite X (LAS X), and produces an error: `Cannot read TIFF header.`

Alternatively, the [scikit-image package](https://scikit-image.org/docs/dev/api/skimage.io.html) uses the [tifffile](https://pypi.org/project/tifffile/) package for reading and writing TIFF files. While it also produces an error message when reading compressed TIFF files generated by LAS X, 
> <path_to_conda_env>\lib\site-packages\skimage\external\tifffile\tifffile.py:2618: RuntimeWarning: py_decodelzw encountered unexpected end of stream

it still reads the TIFF file correctly.