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
