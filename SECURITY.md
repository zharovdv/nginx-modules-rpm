# Security policy

## Supported versions

Security fixes are provided through newly published packages for currently supported official nginx.org stable releases. Older RPMs remain available for ABI compatibility but should not be interpreted as actively supported versions.

## Reporting a vulnerability

Do not open a public issue for vulnerabilities involving package integrity, signing keys, workflows, build provenance or a practical security flaw in a published package.

Use GitHub's private vulnerability reporting feature:

1. open the repository's **Security** tab;
2. select **Advisories**;
3. select **Report a vulnerability**.

Include the affected package and version, impact, reproduction steps and any suggested mitigation. Reports will be acknowledged as soon as practical. Please allow reasonable time for investigation and remediation before public disclosure.

For vulnerabilities in NGINX, Nchan or GeoIP2 source code rather than this packaging project, follow the upstream project's security policy. This repository cannot issue upstream source fixes.

Never send private signing keys or production credentials with a report.
