# Community announcement drafts

Check each project's contribution guidelines and search existing discussions before posting. Prefer a Discussion when available. Open an Issue only when the upstream project accepts packaging or documentation requests there.

## Nchan upstream

**Title:** Community RPM repository for Nchan and official nginx.org EL9 packages

I maintain an unofficial community DNF repository providing signed Nchan dynamic-module RPMs for the official nginx.org stable packages on RHEL, Rocky Linux and AlmaLinux 9 x86_64.

The packages are built with `nginx/pkg-oss`, pinned to reviewed upstream commits and the exact NGINX ABI, installed in a disposable EL9 environment and exercised with a real publish/subscribe SSE smoke test. RPMs and repository metadata are signed, and releases include checksums, build information and GitHub build-provenance attestations.

Project: https://github.com/zharovdv/nginx-modules-rpm

Repository: https://zharovdv.github.io/nginx-modules-rpm/

This is explicitly an unofficial community project and does not request support responsibility from Nchan maintainers. If you consider it useful to EL9 users, would you be open to linking it from the installation documentation or a community-packages section? I am happy to adjust the wording or placement to match the project's policy.

## GeoIP2 module upstream

**Title:** Community RPM repository for ngx_http_geoip2_module and official nginx.org EL9 packages

I maintain an unofficial community DNF repository providing signed `ngx_http_geoip2_module` RPMs for the official nginx.org stable packages on RHEL, Rocky Linux and AlmaLinux 9 x86_64.

The packages are built with `nginx/pkg-oss`, pinned to reviewed upstream commits and the exact NGINX ABI, installed in a disposable EL9 environment and exercised by starting NGINX and verifying a module-backed variable through a real HTTP request. RPMs and repository metadata are signed, and releases include checksums, build information and GitHub build-provenance attestations.

Project: https://github.com/zharovdv/nginx-modules-rpm

Repository: https://zharovdv.github.io/nginx-modules-rpm/

This is explicitly an unofficial community project and does not request support responsibility from upstream maintainers. If you consider it useful to EL9 users, would you be open to linking it from the installation documentation or a community-packages section? I am happy to adjust the wording or placement to match the project's policy.

## General community post

**Title:** Signed Nchan and GeoIP2 RPM repository for official nginx.org packages on EL9

I have published an unofficial community DNF repository for Nchan and GeoIP2 dynamic modules built against official nginx.org stable packages on RHEL-compatible EL9 x86_64 systems.

The build pipeline uses immutable reviewed source pins, checks the exact NGINX ABI, installs every RPM in a disposable Rocky Linux 9 environment and runs module-specific runtime smoke tests. Packages and repository metadata are signed. Build information, checksums and GitHub provenance attestations are published with each release.

Installation instructions and available packages:

https://zharovdv.github.io/nginx-modules-rpm/

Source and CI:

https://github.com/zharovdv/nginx-modules-rpm

Feedback from EL9 users is welcome, especially around installation, compatibility and additional runtime validation. This is a community project and is not affiliated with NGINX, F5 or the upstream module authors.
