# Upstream dependency updates

The repository separates update discovery, validation, review and publication. Discovering a new release never signs or publishes an RPM.

## Automated update flow

The `Propose upstream pin updates` workflow runs every Monday and can also be started manually. It resolves:

- the newest stable NGINX release from even-minor `nginx/pkg-oss` tags;
- the exact commit behind the matching `pkg-oss` tag;
- the newest stable Nchan tag and its dereferenced commit;
- the newest stable GeoIP2 module tag and its commit.

If the resolved values differ from `pins.env`, the workflow creates or updates the `automation/update-upstream-pins` branch and opens one pull request. It then explicitly dispatches the build and lint workflows for that branch.

The update pull request must be reviewed and merged by a maintainer. It never triggers a release. After merge, use the module release workflow when new signed RPMs are required.

## Required GitHub setting

Open **Settings → Actions → General → Workflow permissions** and configure:

1. **Read and write permissions**;
2. **Allow GitHub Actions to create and approve pull requests**.

The workflow grants itself only `actions: write`, `contents: write` and `pull-requests: write`. Repository or organization policy can still restrict those permissions.

## Manual use

Run **Actions → Propose upstream pin updates → Run workflow**. When no updates exist, the workflow finishes without creating a branch or pull request.

For diagnostics, `update-pins` can be run locally:

```bash
./update-pins
git diff -- pins.env
```

The script changes `pins.env` only. Review the diff and use the ordinary CI before committing it.

## Manual discovery builds

`Build and test RPM` retains a manual `discovery` mode for testing a specific moving `pkg-oss` ref or repository channel without modifying reviewed pins. Discovery builds have read-only repository permissions and cannot publish anything.
