# Bash

Bash manual: https://www.gnu.org/software/bash/manual/bash.html

## Redirection

Print to stdout: `echo "hello"`\
Print to stderr: `echo "hello" 1>&2`

Redirect stdout: `1>` == `>`\
Pipe stdout: `|`\
Redirect stderr: `2>`\
Pipe stderr: `2>&1 1> /dev/null |`\
Redirect stderr and pipe stdout: `2> tmp.txt |`\
Redirect stdout and pipe stderr: `2>&1 1> tmp.txt |`\
Redirect stdout and stderr: `&>` == `> tmp.txt 2>&1` == `2> tmp.txt 1>&2`
Pipe stdout and stderr: `2>&1 |`

Pipe stdout to a command that normally reads from a file
- `echo "stdout text" | command /dev/stdin/`
- By convention (not a shell construct), commands will read from standard input if given `-` as the last argument
  - Examples: tar, sed, sort
  - See https://www.gnu.org/software/coreutils/manual/coreutils.html#Common-options

# Text processing

GNU Coreutils manual: https://www.gnu.org/software/coreutils/manual/coreutils.html

## Extracting lines

Given
- line numbers (`$L1`, `$L2`): `sed -n "$L1,$L2p" /path/to/file`
- regex (`$reg`): `grep -E -e $reg /path/to/file`

# OpenSSH

## Port forwarding

`ssh` options
- `-L [bind:]<loc_port>:<host>:<host_port>`: forwards all network requests on the local machine's `<loc_port>` port to the `<host>:<host_port>` on `<remote>`
  - `[bind:]<loc_port>` = the local port from which to forward network requests. If `bind` is not set, then anyone with access to the local machine's `<loc_port>` (e.g. over the same Wi-Fi network) can also see the forwarded requests. To restrict `<loc_port>` access to the local machine itself, set `bind` = `localhost`
  - `<host>:<host_port>` = the host port (from `<remote>`'s perspective) that is receiving forwarded network requests
    - Typically `<host>` = `localhost`
    - `<host>` may also be a network address (e.g., if `<remote>` is a login node and `<host>` is a compute node)
      - Firewalls may limit the range of accessible `<host_port>` numbers (e.g., on wheat and oat Farmshare nodes, `<host_port>` needs to be > 32768)
- `-N`: do not execute a remote command
- `-f`: go to background just before command execution

Direct port forwarding: `ssh -N -L [bind:]<loc_port>:<host>:<host_port> <user>@<remote>`
- Example: forward localhost:8889 to rice05:50000
    ```ssh -Nf -L localhost:8889:localhost:50000 bentyeh@rice05.stanford.edu```
- Example: forward localhost:8889 to wheat16:50000 through rice05
    ```ssh -Nf -L localhost:8889:wheat16.stanford.edu:50000 bentyeh@rice05.stanford.edu```

Multiple hop port forwarding: `ssh -L [bind:]<loc_port>:<middle_host>:<middle_port> <user>@<middle_host> ssh -N -L <middle_port>:<host>:<host_port> <remote>`
- Does not work if two-factor authentication is required between `<middle_host>` and `<remote>` (e.g., on Farmshare)
- Example: forward localhost:8889 through login.sherlock.stanford.edu:40000 to sh-08-25.int:50000
  ```ssh -f -L localhost:8889:localhost:40000 bentyeh@login.sherlock.stanford.edu ssh -N -L 40000:localhost:50000 sh-08-25.int```

