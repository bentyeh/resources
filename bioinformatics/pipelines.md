# Snakemake

Syntax and notes to self
- Command line interface: https://snakemake.readthedocs.io/en/stable/executing/cli.html
- Snakefiles (workflows): https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html
  - Each rule contains one of `run`/`shell`/`script`/`notebook`/`wrapper`/`template_engine`/`cwl` keywords
  - Supported directives: see the `norunparams` line
    - `input`
    - `output`
    - `params`
    - `message`
    - `threads`
    - `resources`
    - `log`: "unlike output files, log files are not deleted upon error" [[source](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#log-files)]
    - `conda`: ignored unless `--use-conda` flag is set as a command line argument
    - `container`
    - `benchmark`
    - `cache`
    - `priority`

Hierarchy of configurations
- Command line
- Snakefile: specify via `--snakefile FILE` command line argument
- Configuration file: specify via `--configfile FILE` command line argument or `configfile: "path/to/config.yaml"` Snakefile directive
- Profile: specify via `--profile FILE` command line argument


Documentation notes
- The word "directive" is used in the documentation to refer to both 