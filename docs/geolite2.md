# GeoLite2 database packages

This project can publish the MaxMind GeoLite2 Country, City and ASN databases as signed `noarch` RPM packages:

| RPM package | Installed file |
| --- | --- |
| `maxmind-geolite2-country` | `/usr/share/GeoIP/GeoLite2-Country.mmdb` |
| `maxmind-geolite2-city` | `/usr/share/GeoIP/GeoLite2-City.mmdb` |
| `maxmind-geolite2-asn` | `/usr/share/GeoIP/GeoLite2-ASN.mmdb` |
| `maxmind-geolite2` | Metapackage that installs all three databases |

## Licensing and data lifecycle

This product includes GeoLite2 Data created by MaxMind, available from <https://www.maxmind.com>.

GeoLite2 data is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and is subject to the [MaxMind GeoLite2 EULA](https://www.maxmind.com/en/geolite/eula). Review those terms before enabling public redistribution. The EULA includes attribution, downstream disclosure and data-retention obligations. Obtain legal advice when necessary; this repository is not legal advice.

The release workflow keeps only the newest `maxmind-geolite2-*` GitHub Release after the new release has been published successfully. Repository users must also update deployed packages and remove superseded database copies within the period required by the current MaxMind terms.

## MaxMind account setup

1. Create or use a MaxMind account with GeoLite2 downloads enabled.
2. Create a license key in the MaxMind account portal. Give it the project name `nginx-modules-rpm`.
3. In GitHub, create an environment named `geolite2-discovery` without required reviewers or a wait timer.
4. Add these environment secrets to `geolite2-discovery`:
   - `MAXMIND_ACCOUNT_ID`: the numeric MaxMind account ID;
   - `MAXMIND_LICENSE_KEY`: the generated license key.
5. Keep `RPM_GPG_PRIVATE_KEY` and `RPM_GPG_KEY_ID` in the protected `release` environment.
6. Remove the two MaxMind secrets from `release` after verifying that they exist in `geolite2-discovery`.

The discovery environment can read the free databases but cannot sign or publish a package. The protected release environment can sign the verified unsigned artifacts but does not receive MaxMind credentials. The credentials are never stored in an RPM, workflow artifact, release asset, build-information file or repository metadata.

## Publishing an update

The workflow checks MaxMind once a day and can also be started manually through **Actions → Build, sign and release GeoLite2 databases → Run workflow**. No version input is required. If the current bundle is already published, the workflow exits before building and does not request release approval. Use the manual `force_rebuild` option only for an intentional packaging-only revision; it keeps unchanged data RPMs and increments the metapackage RPM release.

When at least one database changes, the discovery job builds the current bundle. It then replaces unchanged data RPMs with the byte-for-byte identical signed RPMs from the previous release. The protected `release` job waits for approval, verifies the bundle, signs only new RPMs and publishes it.

Each data package has an independent version based only on that database's release date and a numeric RPM release. If MaxMind corrects an archive without changing its date, the RPM release increments from `-1` to `-2`. For example:

- `maxmind-geolite2-country-2026.09.18-1.el9.noarch`;
- `maxmind-geolite2-city-2026.09.18-1.el9.noarch`;
- `maxmind-geolite2-asn-2026.09.19-1.el9.noarch`.

The `maxmind-geolite2` metapackage uses the newest database date plus a bundle sequence, for example `2026.09.20.1-1`. If another database changes while the newest date stays the same, the next metapackage version is `2026.09.20.2-1`. The sequence resets to `.1` when the newest date advances. Its RPM release increments only when packaging changes without changing the database bundle. The GitHub release tag contains the complete version and release, for example `maxmind-geolite2-2026.09.20.1-1`.

The exact three-database state remains in `build-info.txt` and `SHA256SUMS`. Consequently, when only ASN changes, DNF upgrades ASN and the small metapackage; Country and City retain their existing NEVRA and exact signed RPM bytes. Individual dates and source hashes are recorded in `build-info.txt`.

The first run after upgrading from legacy hash-based RPM releases automatically republishes the current bundle once with numeric RPM releases. Existing hash-based data packages become numeric release `-2`, which sorts newer in RPM version ordering. Future database dates start again at `-1`. The superseded release is removed only after the replacement is published. Later runs with the same bundle exit without requesting approval.

The workflow:

1. checks all three official release dates without consuming a database download when no update exists;
2. downloads all three official archives and their SHA-256 files over HTTPS when an update exists;
3. verifies every archive, validates every MMDB file and builds the current RPM set;
4. reuses exact previously signed RPMs for databases whose NEVRA did not change;
5. pauses at the protected `release` environment;
6. signs the new data RPMs, metapackage and DNF repository metadata after one approval;
7. publishes checksums, source hashes, license notice and build provenance;
8. removes superseded GeoLite2 releases;
9. deploys the prepared DNF repository to GitHub Pages without another approval.

If any step before publication fails, no existing database release is removed.

For a local unsigned build, export `MAXMIND_ACCOUNT_ID` and `MAXMIND_LICENSE_KEY`, then run `make geolite2-data`. Artifacts are written below `dist/maxmind-geolite2/<bundle-id>/`.

## NGINX example

Load `ngx_http_geoip2_module.so` in the main NGINX context, then reference the required database:

```nginx
load_module modules/ngx_http_geoip2_module.so;

http {
    geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
        auto_reload 1h;
        $geoip2_country_code country iso_code;
    }
}
```

Use `auto_reload` so long-running NGINX workers reopen a database after an RPM update.
