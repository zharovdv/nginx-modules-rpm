#!/usr/bin/env bash
set -Eeuo pipefail

cat >/etc/nginx/conf.d/module-smoke-test.conf <<'EOF'
variables_hash_max_size 2048;

server {
    listen 127.0.0.1:18080;

    location = /sub {
        nchan_subscriber;
        nchan_channel_id $arg_id;
        nchan_subscriber_first_message newest;
    }

    location = /pub {
        allow 127.0.0.1;
        deny all;
        nchan_publisher;
        nchan_channel_id $arg_id;
    }
}
EOF

nginx -t
nginx

subscriber_output="$(mktemp)"
subscriber_pid=""

cleanup() {
    if [[ -n "$subscriber_pid" ]]; then
        kill "$subscriber_pid" >/dev/null 2>&1 || true
        wait "$subscriber_pid" 2>/dev/null || true
    fi

    rm -f "$subscriber_output"
    nginx -s quit >/dev/null 2>&1 || true
}

trap cleanup EXIT

curl --fail --silent --show-error --no-buffer \
    --max-time 10 \
    -H "Accept: text/event-stream" \
    "http://127.0.0.1:18080/sub?id=smoke" >"$subscriber_output" &
subscriber_pid=$!

published=false

for _ in {1..50}; do
    publisher_status="$(
        curl --silent --show-error \
            --output /dev/null \
            --write-out "%{http_code}" \
            --data "nchan-smoke-ok" \
            "http://127.0.0.1:18080/pub?id=smoke" \
            || true
    )"

    if [[ "$publisher_status" == 201 ]]; then
        published=true
        break
    fi

    sleep 0.1
done

[[ "$published" == true ]] || {
    printf "Nchan publisher did not find an active subscriber\n" >&2
    exit 1
}

delivered=false

for _ in {1..50}; do
    if grep -Fq "nchan-smoke-ok" "$subscriber_output"; then
        delivered=true
        break
    fi

    sleep 0.1
done

[[ "$delivered" == true ]] || {
    printf "Nchan subscriber did not receive the published message\n" >&2
    exit 1
}
