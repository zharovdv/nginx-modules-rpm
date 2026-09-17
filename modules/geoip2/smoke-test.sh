#!/usr/bin/env bash
set -Eeuo pipefail

cat >/etc/nginx/conf.d/module-smoke-test.conf <<'EOF'
geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
    auto_reload 5m;
    $smoke_country_code default=ZZ source=$remote_addr country iso_code;
}
server {
    listen 127.0.0.1:18080;
    location = /health { return 200 "$smoke_country_code\n"; }
}
EOF

nginx -t
nginx
trap 'nginx -s quit 2>/dev/null || true' EXIT

for _ in {1..30}; do
    response="$(curl --fail --silent --show-error --max-time 2 http://127.0.0.1:18080/health 2>/dev/null || true)"
    [[ "$response" == ZZ ]] && exit 0
    sleep 0.2
done

printf 'Unexpected GeoIP2 health response: %q\n' "${response:-}" >&2
exit 1
