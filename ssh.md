# OpenSSH

Options can be either given on the command line when invoking `ssh` (see `man ssh`) or in a user configuration file at `~/.ssh/config` (see `man ssh_config`).

All SSH utilities (see https://www.openssh.org/manual.html)
- `ssh` — The basic rlogin/rsh-like client program
- `sshd` — The daemon that permits you to log in
- `ssh-agent` — An authentication agent that can store private keys
- `ssh-add` — Tool which adds keys to in the above agent
- `ssh-keygen` — Key generation tool
- `ssh-keyscan` — Utility for gathering public host keys from a number of hosts
- `ssh-keysign` — Helper program for host-based authentication
- `sftp` — FTP-like program that works over SSH1 and SSH2 protocol
- `scp` — File copy program that acts like rcp
- `sftp-server` — SFTP server subsystem (started automatically by sshd)

Additional manuals (`ssh_config` is not a program; `man ssh_config` will display the manual for the client configuration file)
- `ssh_config` — The client configuration file
- `sshd_config` — The daemon configuration file

# Client Configuration

See `man ssh_config`.

Order of priority
1. command-line options
2. user's configuration file (~/.ssh/config)
3. system-wide configuration file (/etc/ssh/ssh_config)

Configuration file syntax
- Lines starting with '#' and empty lines are interpreted as comments.
- General structure: sections of parameter-value pairs separated by `Host` specifications. `Host` patterns consist of non-whitespace characters and the wildcards '*' (matches zero or more characters) or '?' (matches exactly one character).

  ```
  Host <pattern1>
      <host1_parameter1> <host1_value1>
      ...

  Host <pattern2>
      <host2_parameter1> <host2_value1>
      ...
  ```

# Example workflow

## Setup

1. Generate private-public key pair: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519-caltech`
   - This creates 2 files:
     - `~/.ssh/id_ed25519-caltech.pub` containing the public key
     - `~/.ssh/id_ed25519-caltech` containing the private key
   - `ssh-keygen` will ask for a passphrase to encrypt the private key.
     - If no passphrase is given, then the private key is stored in plaintext in the file `~/.ssh/id_ed25519-caltech`.
     - If a passphrase is given, then `~/.ssh/id_ed25519-caltech` contains the encrypted private key.

2. Copy the public key to the server: `ssh-copy-id -i ~/.ssh/id_ed25519-caltech.pub btyeh@caltech`
   - This adds the public key (i.e., the contents of `~/.ssh/id_ed25519-caltech.pub`) to `btyeh@caltech:/home/btyeh/.ssh/authorized_keys`
   - `~/.ssh/authorized_keys` in a user's home directory lists public keys that can be used for logging in as the user using a corresponding private key instead of the user password.

3. Update the SSH client configuration file (`~/.ssh/config`) to point to the private key. Note that `UseKeychain` is a macOS-specific configuration keyword.

   ```
   Host caltech
       Hostname login.hpc.caltech.edu
       IdentityFile ~/.ssh/id_ed25519-caltech

   Host *
       AddKeysToAgent yes
       UseKeychain yes
   ```

To inspect the private and public keys that were created:
- public key: `~/.ssh/id_ed25519-caltech.pub`
  - Encryption: none; stored in plaintext
  - Format: OpenSSH public key files contain 3 parts: `<key_type> <key> <comment>`
    - The key type indicates the algorithm used, such as "ssh-ed25519", "ssh-rsa", or "ecdsa-sha2-nistp256".
    - The key is encoded in Base64.
    - The comment is optional and ignored during authentication; it is solely for human identification.
  - The cryptographic hash of a public key is called a **fingerprint**.
    - How to generate: use the `-l` flag of `ssh-keygen`.
      ```bash
      $ ssh-keygen -l -f ~/.ssh/id_ed25519-caltech.pub
      256 SHA256:<value> <comment> (ED25519)           # key size, hash, comment, key type
      ```
      - The same hash can be generated from the private key: `ssh-keygen -l -f ~/.ssh/id_ed25519-caltech`
    - Purpose: verify that another party has the same public key.
      - Since a hash is a one-way summary, the hash can be shared without exposing the actual public key. However, since public keys aren't kept secret anyway, fingerprints primarily offer a practical benefit: short hashes are easier to compare by eye than long public keys.
      - Example: GitHub ([github.com/settings/keys](https://github.com/settings/keys)) shows the fingerprints of public keys that a user has shared with GitHub.
- private key: `~/.ssh/id_ed25519-caltech`
  - Encryption: depends on whether a passphrase was used at generation (see above)
    - The passphrase is converted into an encryption key using a key derivation function (bcrypt), and the private key is encrypted with that key (AES-256 by default). See the [OpenSSH private key format specification](https://github.com/openssh/openssh-portable/blob/master/PROTOCOL.key) for technical details.
    - To check if a private key file is encrypted: `ssh-keygen -y -f ~/.ssh/id_ed25519-caltech`
      - If the file is encrypted, then you will be first prompted for a passphrase. Otherwise, no prompt is displayed.
      - `ssh-keygen -y`: prints the public key corresponding to the specified private key file
        - The output will be identical to the contents of the public key file `~/.ssh/id_ed25519-caltech.pub` (see above) but does not depend on the existence of `~/.ssh/id_ed25519-caltech.pub`.
    - To encrypt (add a passphrase to) an existing private key file, or change the passphrase of an existing encrypted private key file:
      ```bash
      $ ssh-keygen -p -f ~/.ssh/id_ed25519-caltech
      Enter old passphrase:                              # only shown if the file is currently encrypted
      Key has comment '<comment>'
      Enter new passphrase (empty for no passphrase):
      Enter same passphrase again:
      Your identification has been saved with the new passphrase.
      ```
      - The private key itself is unchanged; only its encryption changes. Hence, the public key and its fingerprint are unchanged, and the public key does not need to be re-copied to any servers.
    - To decrypt an existing encrypted private key file (i.e., remove its passphrase):
      ```bash
      $ ssh-keygen -p -f ~/.ssh/id_ed25519-caltech -N ""
      Enter old passphrase:
      Key has comment '<comment>'
      Your identification has been saved with the new passphrase.
      ```
      - `-N ""` sets the new passphrase to the empty string. An empty passphrase means "no passphrase" ([`man ssh-keygen`](https://man.openbsd.org/ssh-keygen)), so the private key is saved unencrypted (in plaintext).
      - Equivalently, run `ssh-keygen -p -f ~/.ssh/id_ed25519-caltech` without `-N ""` and press Enter at both new-passphrase prompts.
      - Despite the message "saved with the new passphrase", the file is no longer encrypted.
  - Format: OpenSSH private key files contain Base64-encoded data between a header and footer line:
    ```
    -----BEGIN OPENSSH PRIVATE KEY-----
    <Base64-encoded data>
    -----END OPENSSH PRIVATE KEY-----
    ```
    - The encoded data includes a copy of the public key, which is always stored unencrypted. This is why the fingerprint can be generated from the private key file without the passphrase (see above).
    - The encoded data also includes the private key and the comment, which are encrypted if a passphrase was used.

## Use

Consider setting up an SSH connection: `ssh btyeh@caltech`

1. The `IdentityFile ~/.ssh/id_ed25519-caltech` line directs the `ssh` client to ask the `caltech` server if it recognizes the public key at `~/.ssh/id_ed25519-caltech.pub` (i.e., if the same public key is at `btyeh@caltech:~/.ssh/authorized_keys`).
2. The server SSH daemon `sshd` recognizes the client's public key, then asks for verification that the client "owns" the key.
3. The client uses the local private key to sign a "challenge" from the server and sends the signature back.

   a. The `ssh` client needs the passphrase to access the private key. The `UseKeychain yes` configuration directs the `ssh` client to get the passphrase from the system keychain (e.g., macOS Keychain) instead of prompting the user.

   b. The `AddKeysToAgent yes` configuration directs the `ssh` client to give the decrypted private key to `ssh-agent`, which holds it in volatile memory (RAM).

   c. Steps 3a and 3b are analogous to manually running `ssh-add ~/.ssh/id_ed25519-caltech`, which will prompt for the passphrase, then add the private key to `ssh-agent`.
      - The `ssh-add --apple-load-keychain` flag is analogous to the `UseKeychain yes` configuration: look for the passphrase from the macOS Keychain first; only prompt the user if it is not found.
      - The passphrase can be manually added to the macOS keychain by using the `--apple-use-keychain` flag. (If only using the `ssh` client with the above configuration file without using `ssh-add --apple-use-keychain` manually, will the passphrase ever get added to the macOS Keychain?)

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

## Multiplexing

How to avoid authentication each time you log in?
- Add the following lines to `~/.ssh/config` on your local machine (i.e., laptop):
  ```
  Host <hostname, e.g., login.sherlock.stanford.edu>
      Hostname <hostname, e.g., login.sherlock.stanford.edu>
      ControlMaster auto
      ControlPersist yes
      ControlPath ~/.ssh/%l%r@%h:%p
  ```
- To control an active connection multiplexing process: `ssh -O <ctl_cmd> <host>`
  - `<ctl_cmd>`
    - `check`: check that the master process is running
    - `stop`: request the master to stop accepting further multiplexing requests
    - `exit`: request the master to exit
  - Example: `ssh -O check sherlock`
- References:
  - [Stanford Farmshare: Connecting](https://srcc.stanford.edu/farmshare2/connecting)
  - [Stanford Sherlock: Avoiding Multiple Duo Prompts](https://www.sherlock.stanford.edu/docs/advanced-topics/connection/#avoiding-multiple-duo-prompts)
  - [Stanford Farmshare: Advanced Connection Options](https://web.stanford.edu/group/farmshare/cgi-bin/wiki/index.php/Advanced_Connection_Options)
  - [Wikibooks: OpenSSH Cookbook - Multiplexing](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing)
  - [OpenSSH client configuration manual](https://man.openbsd.org/ssh_config)
