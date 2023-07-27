# Base Python

### Two ways to call a method

Let `obj = myClass()` be an instance of a `myClass` object, which defines a `myMethod()` method. Then the following statements are equivalent:
1. `obj.myMethod()`
2. `myClass.myMethod(obj)`
   - This statement makes it clear that `obj` is passed into the method as the `self` argument.

# Python Standard Library

## Subprocess

### Saving environment variables after running a subprocess

Relevant StackOverflow posts
- [How to get the environment variables of a subprocess after it finishes running?](https://stackoverflow.com/questions/5905574/how-to-get-the-environment-variables-of-a-subprocess-after-it-finishes-running)
- [How to get environment variables after running a subprocess](https://stackoverflow.com/questions/63723381/how-to-get-environment-variables-after-running-a-subprocess)

My preferred solution is copied below:

```{python}
# source: https://stackoverflow.com/a/68339760
import json
import os
import subprocess
import sys
from contextlib import AbstractContextManager

class BashRunnerWithSharedEnvironment(AbstractContextManager):
    """
    Run multiple bash scripts with persisent environment.
    Environment is stored to "env" member between runs. This can be updated
    directly to adjust the environment, or read to get variables.
    """

    def __init__(self, env=None):
        if env is None:
            env = dict(os.environ)
        self.env: Dict[str, str] = env
        self._fd_read, self._fd_write = os.pipe()

    def run(self, cmd, **opts):
        if self._fd_read is None:
            raise RuntimeError("BashRunner is already closed")
        write_env_pycode = ";".join(
            [
                "import os",
                "import json",
                f"os.write({self._fd_write}, json.dumps(dict(os.environ)).encode())",
            ]
        )
        write_env_shell_cmd = f"{sys.executable} -c '{write_env_pycode}'"
        cmd += "\n" + write_env_shell_cmd
        result = subprocess.run(
            ["bash", "-ce", cmd], pass_fds=[self._fd_write], env=self.env, **opts
        )
        self.env = json.loads(os.read(self._fd_read, 5000).decode())
        return result

    def __exit__(self, exc_type, exc_value, traceback):
        if self._fd_read:
            os.close(self._fd_read)
            os.close(self._fd_write)
            self._fd_read = None
            self._fd_write = None

    def __del__(self):
        self.__exit__(None, None, None)
```

# Packages

## Numpy

NumPy array broadcasting tutorial: https://jakevdp.github.io/PythonDataScienceHandbook/02.05-computation-on-arrays-broadcasting.html

## Jupyter

### Installing multiple kernels

Notes
- IPython 5.x is the last version of IPython to support Python 2.

References
- https://ipython.readthedocs.io/en/latest/install/kernel_install.html
- https://docs.anaconda.org/anaconda/user-guide/tasks/use-jupyter-notebook-extensions/
- https://stackoverflow.com/questions/53004311/how-to-add-conda-environment-to-jupyter-lab

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

### Interacting with the Jupyter Server

> Jupyter Server is the backend—the core services, APIs, and REST endpoints—to Jupyter web applications.
>
> Most of the time, you won’t need to start the Jupyter Server directly. Jupyter Web Applications (like Jupyter Notebook, Jupyterlab, Voila, etc.) come with their own entry points that start a server automatically.
>
> Sometimes, though, it can be useful to start Jupyter Server directly when you want to run multiple Jupyter Web applications at the same time.
>
> ... every Jupyter frontend application is now a server extension.

Examples
- List available extensions: (terminal) `jupyter server extension list`
- Get list of active kernels: (HTTP GET request) `http://<server address>/api/kernels`
  - For example, if a server is launched listening to port `8888` on `localhost`, you can run: (terminal) `curl -X GET "http://localhost:8888/api/kernels?token=<token>"`

Example use case: As of July 2023, the VSCode Jupyter extension [[marketplace](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) | [GitHub](https://github.com/microsoft/vscode-jupyter)] does not have full kernel management support [[GitHub issue](https://github.com/microsoft/vscode-jupyter/issues/1379)]. For example, if you open a notebook and start it with a *new kernel* on an *existing Jupyter server*, there is no way in the VSCode GUI to shutdown that kernel. To do so, you would have to run `curl -X DELETE "http://localhost:8888/api/kernels/<kernel_id>?token=<token>"` on the host were the Jupyter server was launched. The `<kernel_id>` can be found by inspecting the standard output of the Jupyter server.

- Note: There is an official but experimental extension, Jupyter PowerToys [[marketplace](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.vscode-jupyter-powertoys) | [GitHub](https://github.com/microsoft/vscode-jupyter-powertoys)] that provides a kernel management panel.

References
- https://wasimlorgat.com/posts/how-to-build-your-own-minimal-jupyter-frontend.html
- [Jupyter Server official documentation](https://jupyter-server.readthedocs.io)
  - [REST API](https://jupyter-server.readthedocs.io/en/latest/developers/rest-api.html)

# Miscellaneous

## Loading compressed TIFF images

Matplotlib depends on Pillow for reading all image files beyond PNGs ([see `matplotlib.pyplot.imread` documentation](https://matplotlib.org/api/_as_gen/matplotlib.pyplot.imread.html)). Pillow can read and write uncompressed TIFF files natively but depends on libtiff for compressed TIFF files.

libtiff can fail to read some compressed TIFF files, such as those generated by Leica Application Suite X (LAS X), and produces an error: `Cannot read TIFF header.`

Alternatively, the [scikit-image package](https://scikit-image.org/docs/dev/api/skimage.io.html) uses the [tifffile](https://pypi.org/project/tifffile/) package for reading and writing TIFF files. While it also produces an error message when reading compressed TIFF files generated by LAS X, 
> <path_to_conda_env>\lib\site-packages\skimage\external\tifffile\tifffile.py:2618: RuntimeWarning: py_decodelzw encountered unexpected end of stream

it still reads the TIFF file correctly.