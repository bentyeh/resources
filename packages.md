# Conda

Quick links
- Documentation: https://conda.io/projects/conda/en/latest/index.html
- Search packages hosted by Anaconda: https://anaconda.org/

Assumptions for these notes
- Environment name: `myenv`
- Consider a conda environment installed at `~/miniconda3/envs/myenv`

Environment YAML files
- Basics: https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#sharing-an-environment
- Version specifications: https://docs.conda.io/projects/conda-build/en/latest/resources/package-spec.html#package-match-specifications

Best practices
- Updating environments: `conda env update -n <environment_name> -f <environment_file> --prune` [[conda docs](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#updating-an-environment)]
  - Example: `conda env update -n myenv -f myenv.yml --prune`
  - Unclear if `--prune` actually works as intended: see [conda 4.7.1 release notes](https://conda.io/projects/conda/en/latest/release-notes.html#deprecations-breaking-changes)
- Using pip with conda
  - Specify pip packages in an environment file

Activating a conda environment from its full path: `conda activate ~/miniconda3/envs/myenv` [[StackOverflow](https://stackoverflow.com/a/46934105)]

History of package installation
- Viewing past commands run: see the file `~/miniconda3/envs/myenv/conda-meta/history`
- Restoring an environment: `conda install --rev <REVNUM>` where `<REVNUM>` corresponds to a revision number shown by `conda list --revisions`
- Creating a environment YAML file from an existing environment, including only packages explicitly specified before: `conda env export --from-history` [[conda docs](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#sharing-an-environment)]
- Generating a minimal set of packages to re-create the environment: see [`conda-tree`](https://github.com/conda-incubator/conda-tree) tool

Specifying a different target platform
- Newer versions (>= [24.3.0](https://github.com/conda/conda/releases/tag/24.3.0)) of conda support a `--platform/--subdir` option for `conda create` and `conda env create` commands. This will cause conda to install packages compiled for different platforms (architectures). [[conda documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#specifying-a-different-target-platform-for-an-environment),[Robin's Blog](https://blog.rtwilson.com/how-to-create-an-x64-intel-conda-environment-on-your-apple-silicon-mac-arm-conda-install/)]
  - In older versions of conda, the same effect could be achieved by setting the `CONDA_SUBDIR` environment variable to the desired platform and running `conda config --env --set subdir <platform>` after activating the environment. [[conda-forge docs](https://conda-forge.org/docs/user/tipsandtricks/#installing-apple-intel-packages-on-apple-silicon)]
- This is particularly useful for Apple Silicon (ARM-based) Mac users (`osx-arm64` platform) trying to install packages only available for the `osx-64` platform, which can still be run on ARM-based Macs through Rosetta.
  - Python installed using `conda create -n test --platform osx-64 python=3.10` in a native Terminal session should automatically run under translation (tested on a M2 Mac running MacOS Sequoia (Version 15.1.1)).
    - This is in contrast to [earlier solutions](https://taylorreiter.github.io/2022-04-05-Managing-multiple-architecture-specific-installations-of-conda-on-apple-M1/) that required the entire Terminal session to be [run using Rosetta](https://blog.hao.dev/setting-up-zsh-with-vs-code-on-apple-silicon-mac-m1-chip).
  - To check if a program is running under Rosetta translation:
    - (Python) Under translation, `platform.machine()` outputs `x86_64`, whereas a natively installed Python interpreter outputs `arm64`.
    - `arch` command: outputs `i386` when run translated on an ARM-based Mac or `arm64` when run natively [[StackOverflow](https://stackoverflow.com/questions/71065636/how-can-i-run-a-command-or-script-in-rosetta-from-terminal-on-m1-mac)]
    - `sysctl.proc_translated` flag: check using `sysctl sysctl.proc_translated`, where a value of 0 indicates a native process, and 1 indicates a translated process. [[Apple Developer documentation](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment), [StackOverflow](https://stackoverflow.com/questions/72888632/how-to-check-if-python-is-running-on-an-m1-mac-even-under-rosetta)]
    - Both `arch` and `sysctl sysctl.proc_translated` can be run from within Python using `subprocess.run`.
  - Example: Bioconda has only compiled the latest versions of many packages for the `osx-arm64` platform (see listing of all available packages here: https://conda.anaconda.org/bioconda/osx-arm64/), whereas it has a [much more extensive catalogue](https://conda.anaconda.org/bioconda/osx-64/) available for the `osx-64` platform.

Known issues with conda environments
- Conda does not always take precedence over locally-installed packages.
  - If the Python variable [`site.ENABLE_USER_SITE`](https://docs.python.org/3/library/site.html#site.ENABLE_USER_SITE) is `True` (which depends on the Python installation), then Python adds the user site-packages directory (which is accessible via the variable [`site.USER_SITE`](https://docs.python.org/3/library/site.html#site.USER_SITE)) to `sys.path`. This path is apparently added to `sys.path` before the conda site-packages directory, such that the user site-packages take precedence over packages in an activated conda environment.
  - Workarounds
    - Set the environment variable [`PYTHONNOUSERSITE`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONNOUSERSITE) to `True` (i.e., `export PYTHONNOUSERSITE=True`) or launch Python with the [`-s`](https://docs.python.org/3/using/cmdline.html#cmdoption-s) flag to exclude the user-site packages directory from `sys.path`.
    - Delete the user-site package directory.
    - Manually edit [site.py](https://docs.python.org/3/library/site.html) in the conda Python such that `site.ENABLE_USER_SITE` is False.
  - References
    - Conda GitHub issue: https://github.com/conda/conda/issues/448
    - StackOverflow: https://stackoverflow.com/questions/25584276/how-to-disable-site-enable-user-site-for-an-environment

Miscellaneous questions
- What is the difference between the [coreutils](https://anaconda.org/conda-forge/coreutils) and [gnu-coreutils](https://anaconda.org/conda-forge/gnu-coreutils) packages in conda-forge?
  - Short answer: gnu-coreutils comes with the same programs as coreutils, but all the program names start with an extra "g" prefix.
  - Long answer: Both share the same GitHub respository (https://github.com/conda-forge/coreutils-feedstock). The only difference between their build recipes is that the [gnu-coreutils build script](https://github.com/conda-forge/coreutils-feedstock/blob/main/recipe/build_gnu-coreutils.sh) adds an option `--program-prefix=g` to the [configure script](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/autoconf.html#Transformation-Options). This is also evident by using the [conda metadata browser](https://conda-metadata-app.streamlit.app/) to compare the files included in each package.