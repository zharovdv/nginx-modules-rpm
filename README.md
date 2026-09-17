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
- `repository.yml` runs after a release and can also be rerun manually without rebuilding or replacing that release;
- the release workflow signs every RPM, verifies the signing-key fingerprint, emits GitHub build-provenance attestations, refuses to overwrite an existing release, rebuilds the complete DNF repository from all releases, signs its metadata, and publishes it through GitHub Pages.

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

## DNF repository

Enable GitHub Pages once under `Settings` → `Pages` → `Build and deployment` by selecting `GitHub Actions` as the source. Every successful release then rebuilds and publishes the complete signed repository automatically:

```text
https://zharovdv.github.io/nginx-modules-rpm/el9/x86_64/
```

Install the repository definition and a module manually with:

```bash
sudo dnf config-manager --add-repo \
    https://zharovdv.github.io/nginx-modules-rpm/nginx-modules-rpm.repo
sudo dnf install nginx-module-nchan
```

Both RPM signatures and repository metadata signatures are checked. The repository retains packages from all GitHub releases so DNF can select the package satisfying the installed official nginx.org ABI.

## Production installation with Ansible

The included Ansible role configures the permanent DNF repository, imports the pinned public-key fingerprint, installs the requested modules, and enables them in the main context of `/etc/nginx/nginx.conf`. It never builds on the target host and never follows a version-specific GitHub Release URL.

Copy `ansible/roles/nginx_modules` into your Ansible repository and use the included example playbook. The default module is Nchan; set `nginx_modules` to install one or both supported modules.

## Architecture scope

The supported build target is intentionally `linux/amd64` / EL9 x86_64. Add a native ARM64 runner, architecture matrix and separately validated nginx.org aarch64 packages before advertising aarch64 support; do not silently rely on QEMU for production releases.

## Security and provenance

- upstream refs and resolved commits are recorded;
- the reviewed NGINX version and matching pkg-oss commit are pinned together and checked for consistency;
- GitHub releases are immutable by convention;
- checksums cover RPMs and provenance metadata;
- release signing should use a protected environment or external signer.

These are unofficial community builds and are not provided or supported by NGINX or the module authors.
