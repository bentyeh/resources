# Snakemake

Cancelling jobs
- If a job exits with exit code other than 0, then the output files of that job (defined under the `output:` directive of the Snakefile) is automatically deleted by Snakemake.
- If the main snakemake program is stopped via Ctrl+C (SIGINT signal), then the output of files of jobs running at the time are NOT deleted but instead considered "incomplete."
  - Incomplete outputs can be identified by running `snakemake --dry-run` (WITHOUT using `--rerun-incomplete`).
  - Example: There is a bug in the script for a rule that results in some outputs being generated correctly (with exit code 0) and others causing the script to produce an output but hang indefinitely.
    - Ctrl+C to stop the main snakemake program.
    - `snakemake --dry-run` (without `--rerun-incomplete`) to identify incomplete files. Remove them manually.
    - Edit the rule/script to fix the bug.
    - (If the edits made to the rule/script would trigger Snakemake to rerun the rule for all outputs, even those that were previously generated correctly) `snakemake --touch` (without `--rerun-incomplete`) to touch the previously correctly produced outputs.
      - This will NOT create any new output.
    - `snakemake -j <n_jobs>` to re-run the pipeline, only generating new outputs.

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