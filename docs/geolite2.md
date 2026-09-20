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

The workflow checks MaxMind once a day and can also be started manually through **Actions → Build, sign and release GeoLite2 databases → Run workflow**. No version input is required. If the current bundle is already published, the workflow exits before building and does not request release approval.

When at least one database changes, the discovery job builds and uploads unsigned RPMs. The protected `release` job then waits for approval. After approval, it downloads those exact artifacts, signs them and publishes the release.

MaxMind can publish the databases on different days. The RPM version uses the newest date, while the RPM release and GitHub tag include all three dates in Country, City and ASN order. This prevents a collision when only one database changes without changing the newest date. Individual dates and source hashes are recorded in `build-info.txt`.

The workflow:

1. checks all three official release dates without consuming a database download when no update exists;
2. downloads all three official archives and their SHA-256 files over HTTPS when an update exists;
3. verifies every archive, validates every MMDB file and builds unsigned RPMs;
4. pauses at the protected `release` environment;
5. signs three data RPMs plus the metapackage after approval;
6. publishes checksums, source hashes, license notice and build provenance;
7. removes superseded GeoLite2 releases;
8. rebuilds and deploys the signed DNF repository.

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
