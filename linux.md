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
Redirect stdout and stderr: `&>` == `> tmp.txt 2>&1` == `2> tmp.txt 1>&2`\
Pipe stdout and stderr: `2>&1 |`

Pipe stdout to a command that normally reads from a file
- `echo "stdout text" | command /dev/stdin/`
- By convention (not a shell construct), commands will read from standard input if given `-` as the last argument
  - Examples: tar, sed, sort
  - See https://www.gnu.org/software/coreutils/manual/coreutils.html#Common-options

## Startup Files

| login | interactive | .bashrc   | .bash_profile* | example situation                        | example command                    | bash options | 
|-------|-------------|-----------|----------------|------------------------------------------|------------------------------------|--------------| 
| no    | no          | no        | no             | running a script                         | `bash myscript.sh`                 | `bash -c`    | 
| no    | yes         | yes       | no             | launching a new shell                    | `screen`                           | `bash`       | 
| yes   | no          | usually** | yes            | non-interactive login to remote computer | `ssh sherlock "echo hi > tmp.txt"` | `bash -l -c` | 
| yes   | yes         | usually** | yes            | interactive login to remote computer     | `ssh sherlock`                     | `bash -l`    | 

\* Bash looks for \~/.bash_profile, \~/.bash_login, and \~/.profile, in that order, and executes commands from the first one that exists.
\*\* By default in Ubuntu, .bashrc is sourced by .profile but exits immediately if the shell is not run interactively.

Default startup files are stored in the directory /etc/skel/ and are copied to a new user's home directory when such user is created by the `useradd` program.

References
- [Bash Manual: 6.2 Bash Startup Files](https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files)
- [Ask Ubuntu: Differentiate login and interactive shells](https://askubuntu.com/questions/879364/differentiate-interactive-login-and-non-interactive-non-login-shell)
- [/etc/skel/ directory](http://www.linfo.org/etc_skel.html)

# Text processing

GNU Coreutils manual: https://www.gnu.org/software/coreutils/manual/coreutils.html

## Extracting lines

Given
- line numbers (`$L1`, `$L2`): `sed -n "$L1,$L2p" /path/to/file`
- regex (`$reg`): `grep -E -e $reg /path/to/file`

## X11 forwarding

Options
- `-C`: gzip-compress all traffic - desirable on slower networks
- `-X`: Enables X11 forwarding
- `-Y`: Enables trusted X11 forwarding. This is *less secure* than `-X` but may be required for compatibility. On Debian (e.g., Ubuntu) systems, `-X` defaults to `-Y`.

# Local software installation

Typical setup (see https://askubuntu.com/a/633924)
- Binaries: place in `$HOME/bin/` (example: `$HOME/bin/pandoc`)
  - Add `$HOME/bin` to `PATH`, such as in `.bashrc`: `PATH="$HOME/bin:$PATH"`
- Man pages: place in `$HOME/share/man/` (example: `$HOME/share/man/man1/pandoc.1.gz`)
  - Add `$HOME/share/man` to `MANPATH`, such as in `.bashrc`: `MANPATH="$HOME/share/man:$MANPATH"`
