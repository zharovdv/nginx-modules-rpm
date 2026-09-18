# NGINX dynamic modules RPM repository

[![CI](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/ci.yml/badge.svg)](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/ci.yml)
[![Lint](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/lint.yml/badge.svg)](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/lint.yml)
[![DNF repository](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/repository.yml/badge.svg)](https://github.com/zharovdv/nginx-modules-rpm/actions/workflows/repository.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Signed community RPM packages for third-party NGINX dynamic modules, built against the official nginx.org packages for Enterprise Linux 9.

Supported modules:

- [`nginx-module-nchan`](https://github.com/slact/nchan);
- [`nginx-module-geoip2`](https://github.com/leev/ngx_http_geoip2_module).

Supported platform:

- RHEL, Rocky Linux and AlmaLinux 9;
- x86_64;
- official nginx.org stable packages.

Packages are bound to the exact nginx.org ABI through `nginx-r<version>`. Nothing is compiled on production servers.

> [!IMPORTANT]
> These are unofficial community packages. This project is not affiliated with or supported by NGINX, F5, Nchan, GeoIP2, Rocky Linux, AlmaLinux or Red Hat.

## Installation

Configure the official nginx.org repository first, then add this repository:

```bash
sudo curl --fail --silent --show-error --location \
    --output /etc/yum.repos.d/nginx-modules-rpm.repo \
    https://zharovdv.github.io/nginx-modules-rpm/nginx-modules-rpm.repo
```

Install one or both modules:

```bash
sudo dnf install nginx-module-nchan
sudo dnf install nginx-module-geoip2
```

Browse available packages, repository metadata and the signing-key fingerprint at:

<https://zharovdv.github.io/nginx-modules-rpm/>

DNF verifies both RPM signatures and signed repository metadata. The repository retains packages for previous NGINX ABIs so DNF can select a package compatible with the installed official nginx.org package.

## Enabling modules

The official nginx.org configuration does not guarantee a module include directory. Load the required module in the main context, before the `events` block:

```nginx
load_module modules/ngx_nchan_module.so;
load_module modules/ngx_http_geoip2_module.so;
```

Only load modules that are installed and required. Validate and reload NGINX:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Ansible

The included role configures the permanent DNF repository, verifies the pinned signing-key fingerprint, installs the requested packages and adds idempotent `load_module` directives.

Copy `ansible/roles/nginx_modules` into your Ansible repository and use [`ansible/playbook.example.yml`](ansible/playbook.example.yml). The role deploys packages only; it never builds on the target host and never follows a version-specific GitHub Release URL.

## Verification and trust model

Every release:

1. uses reviewed NGINX, `pkg-oss` and module pins from [`pins.env`](pins.env);
2. verifies that the NGINX version matches the pinned `pkg-oss` source;
3. builds inside a digest-pinned Rocky Linux container using the official [`nginx/pkg-oss`](https://github.com/nginx/pkg-oss) tooling;
4. installs the resulting package and checks its exact `nginx-r<version>` requirement;
5. checks shared-library dependencies and runs a module-specific runtime smoke test;
6. signs RPMs and repository metadata with the published project key;
7. publishes checksums, build information and GitHub build-provenance attestations.

Nchan's smoke test performs real publish/subscribe delivery over SSE. GeoIP2's smoke test starts NGINX, performs an HTTP request and verifies a module-backed variable.

The signing key and its fingerprint are available here:

- [`keys/RPM-GPG-KEY-nginx-modules-rpm`](keys/RPM-GPG-KEY-nginx-modules-rpm);
- [`pins.env`](pins.env).

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

Artifacts are written below `dist/nginx-module-<module>/<nginx-version>/<module-version>/`. Each directory contains RPM files, `build-info.txt` and `SHA256SUMS`.

## Local lint

The repository uses ShellCheck for shell analysis, shfmt for shell formatting and actionlint for GitHub Actions workflows. Their reviewed versions and download checksums are committed in [`lint-tools.env`](lint-tools.env).

On Linux x86_64, install the pinned tools and run every check with:

```bash
make lint-tools
PATH="$PWD/.cache/lint-tools:$PATH" make lint
```

The same checks run automatically for every pull request and push to `main`.

## Automation

- `ci.yml` builds and tests both modules on pull requests, pushes and daily discovery runs;
- `lint.yml` checks shell code, formatting and GitHub Actions workflows on pull requests and pushes;
- reviewed CI and releases use immutable values committed in `pins.env`;
- discovery runs may inspect moving upstream refs but have read-only permissions;
- `release.yml` manually builds, tests, signs and publishes one reviewed module;
- `repository.yml` rebuilds the complete signed DNF repository from all GitHub Releases and publishes it through GitHub Pages;
- external Actions and the base image are pinned to immutable commits or digests;
- Dependabot proposes dependency updates as reviewable pull requests.

Signing-key creation, backup, GitHub configuration and rotation are documented in [`docs/signing.md`](docs/signing.md).

## Contributing and support

- Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before proposing a new module or build change.
- Use [GitHub Issues](https://github.com/zharovdv/nginx-modules-rpm/issues) for reproducible packaging defects and module requests.
- Use [GitHub Discussions](https://github.com/zharovdv/nginx-modules-rpm/discussions) for installation questions and general ideas.
- Report security problems according to [`SECURITY.md`](SECURITY.md).

The supported build target is intentionally EL9 x86_64. ARM64 requires a native runner, a separate architecture matrix and independent validation before it can be advertised as supported.
