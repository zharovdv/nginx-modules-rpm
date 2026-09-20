.PHONY: build geoip2 geolite2-data nchan lint lint-tools clean

include pins.env

NGINX_REPO ?= stable
NGINX_VERSION ?= $(NGINX_STABLE_CI_VERSION)
PKG_OSS_REF ?= $(PKG_OSS_CI_COMMIT)

export MODULE MODULE_REF NGINX_REPO NGINX_VERSION PKG_OSS_REF

build:
	docker compose build --pull builder
	docker compose run --rm builder

geoip2: MODULE=geoip2
geoip2: MODULE_REF=$(GEOIP2_CI_COMMIT)
geoip2: build

nchan: MODULE=nchan
nchan: MODULE_REF=$(NCHAN_CI_COMMIT)
nchan: build

geolite2-data:
	docker compose build --pull builder
	docker run --rm \
		--volume "$(CURDIR)/dist:/dist" \
		--env MAXMIND_ACCOUNT_ID \
		--env MAXMIND_LICENSE_KEY \
		--env "HOST_UID=$$(id -u)" \
		--env "HOST_GID=$$(id -g)" \
		--entrypoint /usr/local/bin/build-maxmind-geolite2-rpms \
		nginx-modules-rpm-builder:rl9

lint:
	./lint

lint-tools:
	./install-lint-tools

clean:
	rm -rf dist
