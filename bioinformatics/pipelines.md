# Snakemake

> Snakemake offers a domain specific language (DSL) for defining workflows... the language extends the syntax of Python with **directives** to define rules and other workflow specific controls. Technically, this is implemented as a hierarchy of [Mealy machines](https://en.wikipedia.org/wiki/Mealy_machine), each of which is responsible for one of the directives offered by the Snakemake DSL. [[docs](https://snakemake.readthedocs.io/en/v9.4.0/project_info/codebase.html), emphasis mine]

Cancelling jobs
- If a job exits with exit code other than 0, then the output files of that job (defined under the `output:` directive of the Snakefile) are automatically deleted by Snakemake.
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
- Snakefiles (workflows): see https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html and https://github.com/snakemake/snakemake-lang-vscode-plugin
  - Each rule contains one of `run`/`shell`/`script`/`notebook`/`wrapper`/`template_engine`/`cwl` keywords
  - Supported directives: see the `norunparams` line
    - `input`
    - `output`
    - `params`
    - `message`
    - `wildcard_constraints`
    - `threads`
    - `resources`
    - `log`: "unlike output files, log files are not deleted upon error" [[docs](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#log-files)]
    - `conda`: ignored unless `--use-conda` (pre-v8) or `--software-deployment-method=conda` (v8+) flag is set as a command line argument
    - `container`
    - `benchmark`
    - `cache`
    - `priority`

Hierarchy of configurations
- Command line
- Workflow profile specified via the `--workflow-profile DIRECTORY` command line argument
- Default workflow profile located at `profiles/default` in the working directory or next to the Snakefile
- Global profile specified via the `--profile DIRECTORY` command line argument
- Default global profile (location is system-dependent, see `snakemake --help`; on Linux, located at `$HOME/.config/snakemake` and `/etc/xdg/snakemake`)
- Workflow configuration file specified via the `--configfile FILE` command line argument
- Workflow configuration file specified via the `configfile: FILE` directive in the Snakefile
- Snakefile-internal directives
- Profile: specify via `--profile FILE` command line argument

Profile configuration files
- The values for certain resources can be Python commands.
  - Example: set a default maximum number of threads per rule that can be overriden by rule-specific configurations.
    ```YAML
    default-resources:
        cpus_per_task: min(int(f"{threads}"), 10)
    set-resources:
        special_rule:
            cpus_per_task: 20
    ```
    This is more flexible than using a global default maximum
    ```YAML
    max-threads: 10
    ```
  - Arbitrary code execution appears possible. For example, the following will print the local variable names and values to the cluster log file for the rule after the rule has finished executing.
    ```YAML
    default-resources:
        cpus_per_task: print(locals())
    ```
  - The `tmpdir` resource does not support Python commands or environment variables. [[GitHub issue #3592](https://github.com/snakemake/snakemake/issues/3592)]
