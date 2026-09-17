.PHONY: build geoip2 nchan clean

build:
	docker compose build --pull builder
	docker compose run --rm --no-build builder

geoip2:
	MODULE=geoip2 $(MAKE) build

nchan:
	MODULE=nchan $(MAKE) build

clean:
	rm -rf dist

