Contents
- [GitHub Authentication and Authorization](#github-authentication-and-authorization)
- [Configuration](#configuration)

<hr>

# GitHub Authentication and Authorization

Terminology
- Authentication: "supply or confirm credentials that are unique to you to prove that you are exactly who you declare to be"
- Authorization: determine what a user is allowed to access or do.

Basic respository access from command line
- SSH remotes: autheticate with GitHub CLI or setup an SSH public/private keypair
  - To setup an SSH public/private keypair:
    1. Generate keypair: `ssh-keygen -t ed25519 -C <GitHub email>`
       - This produces 2 files: `id_ed25519` and `id_ed25519.pub`
    2. [Add the public key in `id_ed25519.pub` to your GitHub account.](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
    - I do not understand the benefits of adding an SSH key passphrase, or how it works. [GitHub's documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases) writes
      > With SSH keys, if someone gains access to your computer, the attacker can gain access to every system that uses that key. To add an extra layer of security, you can add a passphrase to your SSH key. To avoid entering the passphrase every time you connect, you can securely cache the key in the SSH agent.
    
      Is the key cached to a file on disk or in memory? Is this cache temporary (i.e., you would have the enter the passphrase periodically still)? Given that this procedure removes the requirement of entering the passphrase for each connection, how does this address the original concern that an attacker with access to the computer could "gain access to every system that uses that key"?
- HTTPS remotes: authenticate with GitHub CLI, use a credential helper like Git Credential Manager, or use a personal access token
  - How does the Git Credential Manager work, if it does not use a personal access token?

References and resources
- https://docs.github.com/en/authentication/keeping-your-account-and-data-secure


# Configuration

Configuration scopes and files [[docs](https://git-scm.com/docs/git-config)]
- system: `$(prefix)/etc/gitconfig`
  - `$(prefix)` refers to where git is installed. For example, `%(prefix)/bin/` refers to the directory in which the Git executable itself lives. Therefore, if git is installed at `/usr/bin/git`, then `$(prefix)` is `/usr`.
    - This is set during compilation. See the INSTALL file: https://github.com/git/git/blob/master/INSTALL.
- global (user-specific): `$XDG_CONFIG_HOME/git/config` and `~/.gitconfig`
  - > When the `XDG_CONFIG_HOME` environment variable is not set or empty, `$HOME/.config/` is used as `$XDG_CONFIG_HOME`... If both files exist, both files are read in the order given above.
- local (respository-specific): `$GIT_DIR/config`
  - `$GIT_DIR` refers to the `.git` folder
- worktree: `$GIT_DIR/config.worktree`
  - > only searched when extensions.worktreeConfig is present in $GIT_DIR/config
- command: `GIT_CONFIG_{COUNT,KEY,VALUE}` environment variables and the `-c` option

Show configurations by scope: `git config --list --show-scope`


# Errors

## git gc

1. On macOS, running `git gc` yields an error message
   > `warning: unable to unlink '.git/objects/07/f47bd76ded355e641fd0367026047da28ef3d5': Operation not permitted`
   - Problem: the git object files may have the user immutable flag `uchg` set, which can be shown by using `ls -l -O <file>` on macOS.
   - Solution: Run the following command to unset the `uchg` flag on the files that git gc is attempting to remove, then rerun `git gc`.
     - `git gc 2>&1 1> /dev/null | grep -F 'warning: unable to unlink' | sed -e "s/warning: unable to unlink '//" -e "s/': Operation not permitted//" | xargs chflags -v nouchg`
