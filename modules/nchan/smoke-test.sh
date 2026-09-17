#!/usr/bin/env bash
set -Eeuo pipefail

cat >/etc/nginx/conf.d/module-smoke-test.conf <<'EOF'
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
trap 'nginx -s quit >/dev/null 2>&1 || true' EXIT

subscriber_output="$(mktemp)"
curl --fail --silent --show-error --no-buffer \
    --max-time 10 \
    -H "Accept: text/event-stream" \
    "http://127.0.0.1:18080/sub?id=smoke" >"$subscriber_output" &
subscriber_pid=$!

for _ in {1..50}; do
    if curl --fail --silent --show-error \
        --data "nchan-smoke-ok" \
        "http://127.0.0.1:18080/pub?id=smoke" >/dev/null; then
        break
    fi
    sleep 0.1
done

wait "$subscriber_pid" || {
    status=$?
    [[ "$status" -eq 28 ]] || exit "$status"
}

grep -Fq "nchan-smoke-ok" "$subscriber_output"
