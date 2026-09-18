# Contributing

Thank you for helping improve the NGINX dynamic modules RPM repository.

## Before opening an issue

- Use GitHub Discussions for installation help, configuration questions and general ideas.
- Search existing issues and discussions.
- Confirm that the problem affects official nginx.org packages on EL9 x86_64.
- Do not publish private keys, credentials, internal hostnames or other sensitive data.

Use Issues for reproducible packaging defects, CI failures and module requests.

## Pull requests

1. Create a focused branch from `main`.
2. Keep unrelated formatting changes out of the pull request.
3. Follow the existing shell, YAML and Markdown style.
4. Run the relevant local checks and builds when possible.
5. Explain the operational and supply-chain impact of the change.
6. Wait for CI to complete successfully.

Conventional Commits are preferred, for example:

```text
feat(modules): add example module
fix(ci): verify downloaded release assets
docs: clarify repository installation
```

Before submitting shell or workflow changes, run:

```bash
make lint-tools
PATH="$PWD/.cache/lint-tools:$PATH" make lint
```

## Updating existing modules

Update immutable pins in `pins.env` through a reviewed pull request. The NGINX version and its matching `pkg-oss` commit must be updated together. Never replace reviewed release pins with moving branches or tags.

The pull request should identify:

- the upstream release or commit;
- the matching official nginx.org version;
- relevant upstream changes;
- the result of the runtime smoke test.

## Proposing a module

A new module should have:

- an actively maintained public upstream repository;
- a license permitting source and binary redistribution;
- support for NGINX dynamic-module builds;
- a reviewed immutable upstream commit;
- compatibility with official nginx.org EL9 packages;
- an automated runtime smoke test that exercises real module behavior;
- a clear operational use case and maintenance owner.

A module request is not a guarantee that the package will be accepted or maintained. Open a module-request issue before implementing a large addition.

## Security-sensitive changes

Changes to signing, release permissions, pinned Actions, base-image digests, artifact verification or repository publication require especially careful review. Report suspected vulnerabilities privately according to `SECURITY.md` instead of opening a public issue.

By participating, you agree to follow `CODE_OF_CONDUCT.md`.
