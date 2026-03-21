SHELL := /bin/bash
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL := build

.PHONY: verify build launch run reset peek poke where debug-help clean

verify:
	./scripts/verify_toolchain.sh

build:
	./scripts/build.sh

launch:
	./scripts/launch_b2.sh

run: build
	./scripts/launch_b2.sh
	./scripts/run_b2_http.sh

reset:
	./scripts/b2_reset.sh

peek:
	./scripts/b2_peek.sh "$(ADDR)" "$(LEN)"

poke:
	./scripts/b2_poke.sh "$(ADDR)" "$(BYTES)"

where:
	./scripts/b2_where.sh "$(QUERY)"

debug-help:
	./scripts/b2_debug_help.sh

clean:
	mkdir -p build
	find build -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf {} +
