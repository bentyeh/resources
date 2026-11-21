Contents
- [GitHub Authentication and Authorization](#github-authentication-and-authorization)
- [Configuration](#configuration)
- [GitHub deploy keys](#github-deploy-keys)
- [Problems](#problems)
  - [Keeping AI agents from reading SSH private keys](#keeping-ai-agents-from-reading-ssh-private-keys)
- [Errors](#errors)
  - [git gc](#git-gc)

<hr>

# GitHub Authentication and Authorization

Terminology
- Authentication: "supply or confirm credentials that are unique to you to prove that you are exactly who you declare to be"
- Authorization: determine what a user is allowed to access or do.

Basic respository access from command line
- SSH remotes: autheticate with GitHub CLI or setup an SSH public/private keypair
  - To setup an SSH public/private keypair (see [ssh.md](ssh.md) for more details):
    1. Generate keypair: `ssh-keygen -t ed25519 -C <GitHub email>`
       - This produces 2 files: `id_ed25519` and `id_ed25519.pub`
    2. [Add the public key in `id_ed25519.pub` to your GitHub account.](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
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

# GitHub deploy keys

[GitHub deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys) restrict a key to read-only or read+write access to a single repository.

Procedure
1. Generate a public-private key pair with `ssh-keygen` (see [ssh.md](ssh.md))
   - Tip: no passphrase; use a filename that indicates the repository it will be associated with (e.g., `id_ed25519_deploykey-{repo}`)
2. Copy the public key to the GitHub repository settings: https://github.com/{owner}/{repo}/settings/keys
3. Add the following to ~/.ssh/config:

   ```
   Host {repo-alias} # for example, github.com-{repo}
       Hostname github.com
       User git
       IdentityFile ~/.ssh/{private_key_filename}
   ```

4. If cloning the repo for the first time: `git clone git@{repo-alias}:{owner}/{repo}.git`
5. If changing the remote of an existing local repository: `git remote set-url origin git@{repo-alias}:{owner}/{repo}.git`

Example: https://lpembleton.rbind.io/posts/github-deploy-keys/

# Problems

## Keeping AI agents from reading SSH private keys

What is the standard way of using git and SSH with AI agents (e.g., Claude Code) while preventing the AI agent from seeing the plaintext SSH private key?
- In a world without AI agents, plaintext ~/.ssh/id* private key files are fine, since no one else is reading them.
- AI agents with full read access can read plaintext private key files and leak them (whether maliciously or inadvertently). Passphrase-encrypting them prevents AI agents from leaking them but introduces other headaches.
- Note: We still want to allow the AI agent to *use* the keys (e.g., to perform networked git operations), but we do not want the keys themselves to be exposed. In other words, we trust the agent to use the key, but we do not trust it not to share the key.

As described in [ssh.md](ssh.md), when authenticating an SSH connection, `ssh` first tries to get the private key from any socket established by `ssh-agent`. AI agent sandboxes typically block access to Unix sockets, so this fails. Consequently, `ssh` tries to read the private key file ~/.ssh/id* directly. If the file is passphrase-encrypted, then this step also fails.
- On macOS, one can setup SSH to use the macOS Keychain (`UseKeychain yes`), thereby enabling SSH to obtain the passphrase for the private key file.
- On Linux, OpenSSH has no equivalent of `UseKeychain`, so from within the sandbox, ssh can neither get the private key from an agent (sockets blocked) nor decrypt it via a keychain.

Consequently, on Linux, these are the only simple ways I know to allow AI agents to perform SSH operations:
- sandbox enabled, private key unencrypted --> risk of leaking private key as plaintext
  - If using this approach, use repo-specific [GitHub deploy keys (see above)](#github-deploy-keys) to limit exposure.
- sandbox enabled (but allow Unix sockets, e.g., `sandbox.network.allowUnixSockets: true`), private key encrypted
  - (Claude Code) On Linux, unlike on macOS, allowing Unix sockets is an all-or-nothing choice via `sandbox.network.allowUnixSockets`.
- sandbox enabled (but exclude git commands, e.g., `sandbox.excludedCommands: ["git fetch *", "git pull *", "git push *"]`), private key encrypted --> allows violation of the sandbox (such as via git hooks)

More complicated alternatives (suggested by ChatGPT) could allow AI agent-managed Git/SSH operations on Linux while limiting Unix socket access, using encrypted private keys, and preserving sandbox integrity:
- ssh-agent + dedicated container or VM
  - Host: encrypted SSH private key + ssh-agent with socket, exposed to the container
  - Within the container: set `sandbox.network.allowAllUnixSockets: true`
  - See Docker documentation page for this: https://docs.docker.com/ai/sandboxes/configuration/credentials/
  - On HPC systems without root privileges, Docker is typically not available. While Apptainer serves as an alternative, it apparently may not properly isolate Unix sockets (according to ChatGPT).
- Hardware-backed SSH key
- Broker model
- Linux Landlock - unavailable on Caltech HPC running RHEL 9.5

References
- Claude Code's documentation is hard to interpret: https://code.claude.com/docs/en/sandboxing#git-over-ssh-fails-with-the-sandbox-on
- Blog post showing how the socket-based `ssh-agent` works when not blocked by a sandbox: https://patrickmccanna.net/giving-coding-agents-ssh-access-to-other-systems-without-giving-disclosing-secrets/

# Errors

## git gc

1. On macOS, running `git gc` yields an error message
   > `warning: unable to unlink '.git/objects/07/f47bd76ded355e641fd0367026047da28ef3d5': Operation not permitted`
   - Problem: the git object files may have the user immutable flag `uchg` set, which can be shown by using `ls -l -O <file>` on macOS.
   - Solution: Run the following command to unset the `uchg` flag on the files that git gc is attempting to remove, then rerun `git gc`.
     - `git gc 2>&1 1> /dev/null | grep -F 'warning: unable to unlink' | sed -e "s/warning: unable to unlink '//" -e "s/': Operation not permitted//" | xargs chflags -v nouchg`
