# RPM signing

Release RPMs are signed with a dedicated project key. This signature identifies
packages produced by this repository; it does not claim authorship of Nchan,
GeoIP2, NGINX, or `nginx/pkg-oss`.

The current release workflow is non-interactive and does not accept a GPG
passphrase. Use a separate key without a passphrase only for this repository.
Do not reuse a personal GPG key.

## Create the key

Run these commands on a trusted workstation with GnuPG 2.1 or newer installed.
They work in Linux, WSL, and Git Bash with a current Gpg4win installation.
Replace the email address before running them. Check the selected executable
before creating the key:

```bash
gpg --version
```

```bash
KEY_UID="nginx-modules-rpm release signing <YOUR_EMAIL>"

gpg --batch \
    --pinentry-mode loopback \
    --passphrase "" \
    --quick-generate-key \
    "$KEY_UID" \
    rsa3072 sign 2y
```

Read and verify the full 40-character fingerprint:

```bash
KEY_FINGERPRINT="$(
    gpg --batch --with-colons --fingerprint --list-secret-keys "$KEY_UID" |
        awk -F: '$1 == "fpr" { print toupper($10); exit }'
)"

printf "%s\n" "$KEY_FINGERPRINT"
[[ "$KEY_FINGERPRINT" =~ ^[0-9A-F]{40}$ ]]
```

The fingerprint is the public identity of this signing key. It is not secret.

## Export the keys

Create the exports outside the Git repository:

```bash
umask 077

gpg --batch --armor \
    --export-secret-keys "$KEY_FINGERPRINT" \
    >RPM-GPG-PRIVATE-KEY-nginx-modules-rpm

gpg --batch --armor \
    --export "$KEY_FINGERPRINT" \
    >RPM-GPG-KEY-nginx-modules-rpm
```

Check both exports before continuing:

```bash
gpg --show-keys --with-fingerprint RPM-GPG-PRIVATE-KEY-nginx-modules-rpm
gpg --show-keys --with-fingerprint RPM-GPG-KEY-nginx-modules-rpm
```

Store `RPM-GPG-PRIVATE-KEY-nginx-modules-rpm` in an encrypted backup, for
example as a KeePassXC attachment. Never commit it, upload it to a release, or
send it to another person.

The public `RPM-GPG-KEY-nginx-modules-rpm` file is safe to commit and publish.
Copy it to `keys/RPM-GPG-KEY-nginx-modules-rpm` in this repository. Users need
it to verify RPM signatures, and the release workflow attaches it to every
GitHub release.

GnuPG also creates a revocation certificate below its home directory, normally
in `~/.gnupg/openpgp-revocs.d/`. Back up the certificate with the private key.

## Configure the GitHub release environment

Open `Settings` -> `Environments` -> `release`.

Add this environment secret:

| Name | Value |
| --- | --- |
| `RPM_GPG_PRIVATE_KEY` | Complete armored contents of `RPM-GPG-PRIVATE-KEY-nginx-modules-rpm` |

Add this environment variable:

| Name | Value |
| --- | --- |
| `RPM_GPG_KEY_ID` | Full 40-character value of `KEY_FINGERPRINT` |

Replace the placeholder in the committed `pins.env` file with the same value:

```dotenv
RPM_GPG_FINGERPRINT=0123456789ABCDEF0123456789ABCDEF01234567
```

The release workflow imports the private key into a temporary GPG home,
requires its fingerprint to match `pins.env`, signs every RPM, verifies the
result, signs the DNF repository metadata in the same protected job, and
destroys the temporary keyrings. GitHub Pages deployment then runs without a
second release approval.

Restrict the `release` environment to the protected `main` branch. Enable
required reviewers when another maintainer is available to approve releases.

## Verify a released package

Import the public key on a clean EL9 host:

```bash
sudo rpm --import RPM-GPG-KEY-nginx-modules-rpm
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release}: %{summary}\n'
```

Verify a downloaded RPM:

```bash
rpmkeys --checksig --verbose nginx-module-*.rpm
```

The result must report valid digests and a valid signature. Also verify the
release checksums:

```bash
sha256sum --check SHA256SUMS
```

## Rotate or revoke the key

Rotate the key before it expires or immediately if the private key or GitHub
environment may have been compromised:

1. revoke the old key and publish the revocation certificate;
2. remove the old `RPM_GPG_PRIVATE_KEY` secret from GitHub;
3. create a new dedicated signing key;
4. update `RPM_GPG_PRIVATE_KEY`, `RPM_GPG_KEY_ID`, and
   `RPM_GPG_FINGERPRINT` in one reviewed change;
5. publish the new public key and clearly announce the fingerprint change;
6. rebuild and release packages signed by the new key.

Existing packages remain verifiable with the old public key. Never silently
replace a published key file while keeping the old filename without documenting
the new fingerprint.
