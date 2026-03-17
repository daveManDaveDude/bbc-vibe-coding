SHELL := /bin/bash
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL := build

.PHONY: verify build launch run clean

verify:
	./scripts/verify_toolchain.sh

build:
	./scripts/build.sh

launch:
	./scripts/launch_b2.sh

run: build
	./scripts/launch_b2.sh
	./scripts/run_b2_http.sh

clean:
	mkdir -p build
	find build -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf {} +
