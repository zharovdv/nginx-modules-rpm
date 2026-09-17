# nginx-modules-rpm

Reproducible EL9 x86_64 RPM builds of third-party dynamic modules for the official nginx.org packages.

Supported modules:

- `nginx-module-geoip2` from `leev/ngx_http_geoip2_module`;
- `nginx-module-nchan` from `slact/nchan`.

The build uses Rocky Linux 9 and the official `nginx/pkg-oss` tooling. Every package is bound to the nginx.org ABI through `nginx-r<version>`. Nothing is compiled on production servers.

## Local build

Requirements: Docker Engine with Compose v2.

```bash
make nchan
make geoip2
```

Build a particular combination:

```bash
MODULE=nchan \
MODULE_REF=v1.3.8 \
NGINX_REPO=stable \
NGINX_VERSION=1.30.5 \
PKG_OSS_REF=129ae8d35db29ef41b9f610d3c2323e774d6a706 \
docker compose run --build --rm builder
```

Artifacts are written below:

```text
dist/nginx-module-<module>/<nginx-version>/<module-version>/
```

Each artifact directory contains RPM files, `build-info.txt`, and `SHA256SUMS`.

## GitHub Actions

- `ci.yml` builds and tests both modules on pull requests, pushes and daily discovery runs;
- pull requests and pushes load the reviewed NGINX version and 40-character commit SHA values from the committed `pins.env`; related NGINX and pkg-oss pins are visible together in normal PR review;
- before installation, the builder verifies that the explicit NGINX version matches the version packaged by the pinned pkg-oss commit;
- scheduled and manual discovery accepts moving refs but has read-only permissions and cannot publish releases;
- `release.yml` is manual, uses the protected `release` environment and releases the selected module from the exact reviewed values in `pins.env`;
- the release workflow signs every RPM, verifies the signing-key fingerprint, emits GitHub build-provenance attestations, serializes identical releases, and refuses to overwrite an existing release.

Configure the protected `release` environment with secret `RPM_GPG_PRIVATE_KEY` and variable `RPM_GPG_KEY_ID`, using a dedicated unencrypted signing key created only for this repository. Commit its public key as `keys/RPM-GPG-KEY-nginx-modules-rpm` and its full fingerprint as `RPM_GPG_FINGERPRINT` in `pins.env`; the supplied placeholder deliberately makes releases fail closed. The complete creation, backup, GitHub configuration, verification, and rotation procedure is documented in [`docs/signing.md`](docs/signing.md). Require reviewers for that environment when another maintainer is available. Moving values such as `master`, `auto`, and `latest-stable` are discovery-only; reviewed CI and releases use exact inputs.

All external Actions and the Rocky Linux base image are pinned to immutable SHA/digest values. Dependabot is configured to propose their updates as reviewable pull requests.

## Validation

The disposable builder:

1. checks out the exact pkg-oss commit and reads its packaged NGINX version;
2. verifies that the explicit NGINX version and stable/mainline channel agree with pkg-oss;
3. installs that exact official nginx.org RPM and verifies `--with-compat`;
4. resolves and records the exact module and pkg-oss commits;
5. builds RPMs with the already reviewed pkg-oss checkout;
6. checks the exact `nginx-r<version>` requirement and installed RPM capability;
7. installs the package;
8. checks `ldd` for missing libraries;
9. runs a module-specific runtime smoke test.

Nchan's smoke test starts NGINX, subscribes over SSE, publishes a message, and verifies delivery. GeoIP2's test starts NGINX, performs a real HTTP request, and requires the module-backed variable to return its configured `ZZ` default.

## Production installation

Download the RPM matching the exact output of `nginx -v`, verify its RPM signature and `SHA256SUMS`, and install it with `dnf`. The RPM dependency prevents installation beside an incompatible nginx.org package.

The included Ansible role intentionally performs deployment only; it never builds on the target host. Rename downloaded RPMs to `nginx-module-nchan.rpm` and `nginx-module-geoip2.rpm`, place them below `ansible/roles/nginx_modules/files/nginx-modules/`, put the armored public key at `ansible/roles/nginx_modules/files/RPM-GPG-KEY-nginx-modules-rpm`, and run the example playbook. DNF signature checking remains enabled. The role adds idempotent `load_module` directives to the main context of `/etc/nginx/nginx.conf`, because the official nginx.org configuration does not guarantee a module include directory.

For a public YUM repository, generate and sign repository metadata separately with `createrepo_c`. Never store the private signing key in the repository.

## Architecture scope

The supported build target is intentionally `linux/amd64` / EL9 x86_64. Add a native ARM64 runner, architecture matrix and separately validated nginx.org aarch64 packages before advertising aarch64 support; do not silently rely on QEMU for production releases.

## Security and provenance

- upstream refs and resolved commits are recorded;
- the reviewed NGINX version and matching pkg-oss commit are pinned together and checked for consistency;
- GitHub releases are immutable by convention;
- checksums cover RPMs and provenance metadata;
- release signing should use a protected environment or external signer.

These are unofficial community builds and are not provided or supported by NGINX or the module authors.
