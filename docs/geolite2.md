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
2. Create a license key in the MaxMind account portal. Give it a clear name such as `nginx-modules-rpm GitHub Actions`.
3. In GitHub, open **Settings → Environments → release**.
4. Add these environment secrets:
   - `MAXMIND_ACCOUNT_ID`: the numeric MaxMind account ID;
   - `MAXMIND_LICENSE_KEY`: the generated license key.
5. Keep the existing `RPM_GPG_PRIVATE_KEY` secret and `RPM_GPG_KEY_ID` variable in the same environment.

The workflow passes MaxMind credentials directly to the build container. They are never stored in an RPM, release asset, build-information file or repository metadata.

## Publishing an update

Open **Actions → Build, sign and release GeoLite2 databases → Run workflow**. No version input is required. MaxMind can publish the databases on different days, so the RPM bundle version uses the newest release date in the set. The individual release date of every database is recorded in `build-info.txt`.

The workflow:

1. downloads all three official archives and their SHA-256 files over HTTPS;
2. verifies every archive and validates every MMDB file;
3. records the independent release date of every database;
4. builds and signs three data RPMs plus the metapackage;
5. publishes checksums, source hashes, license notice and build provenance;
6. removes superseded GeoLite2 releases;
7. rebuilds and deploys the signed DNF repository.

If any step before publication fails, no existing database release is removed.

For a local unsigned build, export `MAXMIND_ACCOUNT_ID` and `MAXMIND_LICENSE_KEY`, then run `make geolite2-data`. Artifacts are written below `dist/maxmind-geolite2/<version>/`.

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
