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