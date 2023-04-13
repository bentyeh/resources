# AFS

WebAFS: https://afs.stanford.edu/
Documentation: https://uit.stanford.edu/service/afs

# Clusters

## Farmshare

Login nodes: rice01 ... rice15 (but not all numbers in that range)
- List all rice login nodes:
  ```
  dig +noedns +norecurse +short +vc @lbdns1.stanford.edu rice.best.stanford.edu TXT | awk '{ print $3 }' | sed -e "s/\"//g"
  ```

Notes
- [AFS access](https://web.stanford.edu/group/farmshare/cgi-bin/wiki/index.php/AFS)
  - Only rice nodes have AFS access, mounted at `/afs`
    - `~/afs-home` conveniently links to users' AFS home directories
  - To check quota and usage: `fs listquota ~/afs-home`

Documentation
- SRCC: https://srcc.stanford.edu/farmshare2
- Wiki: https://web.stanford.edu/group/farmshare/cgi-bin/wiki/index.php/Main_Page

## Sherlock

Login nodes: sh-ln01 ... sh-ln08

OnDemand: http://sherlock.stanford.edu
- Accessing open ports on nodes: `https://login.sherlock.stanford.edu/rnode/<node>.int/<port>/`
  - Does not seem to work well with Jupyter notebooks

Provided utilities: `sh_...`
- Type `sh_` and then press `<TAB>` twice to see all available utilities.

Documentation: https://www.sherlock.stanford.edu/

## SCG4: Stanford Genomics Cluster

Login nodes: scg4-ln01 (smsx10srw-srcf-d15-35) ... scg4-ln04 (smsx10srw-srcf-d15-38)

Documentation: https://web.stanford.edu/group/scgpm/cgi-bin/informatics/wiki/index.php/Main_Page

# Interactive Environments

## Jupyter

`jupyter notebook --no-browser --ip=0.0.0.0 --port=<port>`
- `--no-browser`: do not automatically search for installed browsers in which to open the notebook after startup
- `--ip=0.0.0.0`: listen to all incoming ports, not just those from 127.0.0.1 (localhost) on the remote machine itself
- `--port=<port>`: port that the notebook server will listen on

Farmshare
- Jupyter needs to be installed by the user, e.g., in a conda environment.
- On compute nodes (wheat, oat), run the following lines before launching Jupyter, and choose a sufficiently high port number > 32768 that is not firewalled
  ```
  mkdir /tmp/$SLURM_JOBID
  export XDG_RUNTIME_DIR=/tmp/$SLURM_JOBID
  jupyter notebook --no-browser --ip=0.0.0.0 --port=<port>
  ```

Sherlock
- Jupyter is available as a Lmod module
  ```
  module load py-jupyter/1.0.0_py36
  module load py-scipystack/1.0_py36
  ```
- Provided script: `sh_notebook`
  - Use `-h` option to see usage documentation
  - Runs Jupyter notebook as a job on a compute/dev node
  - Loads default Python version (2.7.13, as of Feb. 2019)

## RStudio

Farmshare, Sherlock
```
module load rstudio
module load R/3.5.1 [Sherlock only]
rstudio
```

This requires remote display, e.g., X11 or VNC (Farmshare only).
- SSH/X11: `ssh -X <user>@<remote>`
- VNC: see https://srcc.stanford.edu/farmshare2/connecting

## RStudio Server

`rserver --www-address=0.0.0.0 --www-port=<remote_port> --auth-validate-users=1`
- `--www-address` and `--www-port` are equivalent to `--ip` and `--port` for [`jupyter notebook`](#jupyter)
- `--auth-validate-users=1`: validates that authenticated users exist on the host system

Farmshare: not available (see [Unanswered Questions](#unanswered) below)

Sherlock
- RStudio Server is available as part of the `rstudio` Lmod module. By default, loads R 3.4.0 (as of Feb. 2019), unless the desired `R` module is loaded *after* loading `rstudio` as shown below:
  ```
  module load rstudio
  module load R/3.5.1
  ```
- Provided script: `sh_rstudio`
  - Use `-h` option to see usage documentation
  - Runs RStudio Server as a job on a compute/dev node
  - Loads default R version (3.4.0, as of Feb. 2019)

## SSH Tunneling

| Host                     | Direct forward | Forward through login node | Hop-forward through login node | 
|--------------------------|----------------|----------------------------|--------------------------------| 
| Farmshare (login node)   | yes            | n/a                        | n/a                            | 
| Farmshare (compute node) | yes            | yes                        | no*                            | 
| Sherlock (login node)    | yes            | n/a                        | n/a                            | 
| Sherlock (compute node)  | yes            | yes                        | yes                            | 
*due to two-factor authentication between login and compute nodes

Direct forwarding: `ssh -N -L localhost:<loc_port>:localhost:<host_port> <user>@<remote>`
- Directly to host: set `<host>` = `localhost`, `<remote>` = hostname of host
- Through login node: set `<host>` = hostname of host, `<remote>` = hostname of login node

Multiple hop port forwarding: `ssh -L localhost:<loc_port>:localhost:<middle_port> <user>@<middle_host> -N -L <middle_port>:localhost:<remote_port> <remote>`

See [`linux.md`](./linux.md) file for more information.

### forward utility

# Questions

## Unanswered

Sherlock
- How to install R via conda on Sherlock?
- How to load additional packages or activate pip/conda environments on Sherlock when using the provided `sh_dev`/`sh_notebook`/`sh_rstudio` scripts?

Farmshare
- How to run RStudio Server on Farmshare?

Myth
- How to create pip or conda environments on Myth?

## Answered

General
- How to avoid authentication each time you log in?
  - Add the following lines to `~/.ssh/config` on your local machine (i.e., laptop):
    ```
    Host <hostname, e.g., login.sherlock.stanford.edu>
      ControlMaster auto
      ControlPersist yes
      ControlPath ~/.ssh/%l%r@%h:%p
    ```
  - References:
    - https://srcc.stanford.edu/farmshare2/connecting
    - https://www.sherlock.stanford.edu/docs/advanced-topics/connection/#avoiding-multiple-duo-prompts
    - https://web.stanford.edu/group/farmshare/cgi-bin/wiki/index.php/Advanced_Connection_Options