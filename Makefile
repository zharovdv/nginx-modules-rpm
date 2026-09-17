.PHONY: build geoip2 nchan clean

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

clean:
	rm -rf dist
