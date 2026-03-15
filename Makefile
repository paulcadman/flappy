.DEFAULT_GOAL := build

LEAN_CC ?= cc
MACOSX_DEPLOYMENT_TARGET ?= 12.0
RAYLIB_MAKEFILE := Makefile.raylib
RAYLIB_BUILD_DIR := .build/raylib-sdl
RAYLEAN_DIR := .lake/packages/raylean
LIBRARY_PATH := $(shell pkg-config --libs-only-L gmp libuv resvg sdl3 | sed 's/-L//g' | tr ' ' ':')
ASSETS_DIR := assets
BUNDLE_BUILD_DIR := .build/bundle
BUNDLE_GEN := $(BUNDLE_BUILD_DIR)/makeBundle
BUNDLE_INCLUDE_DIR := $(BUNDLE_BUILD_DIR)/include
BUNDLE_HEADER := $(BUNDLE_INCLUDE_DIR)/bundle.h
RESOURCES := $(shell find $(ASSETS_DIR) -type f | sort)
CPATH := $(BUNDLE_INCLUDE_DIR)

LAKE_ARGS :=
ifdef LAKE_NO_ANSI
LAKE_ARGS += --no-ansi
endif
ifdef LAKE_CURDIR
LAKE_ARGS += -d $(LAKE_CURDIR)
endif

$(BUNDLE_GEN): $(RAYLEAN_DIR)/scripts/makeBundle.lean
	mkdir -p $(BUNDLE_BUILD_DIR)
	lean -c $(BUNDLE_GEN).c $(RAYLEAN_DIR)/scripts/makeBundle.lean
	leanc $(BUNDLE_GEN).c -o $(BUNDLE_GEN)

$(BUNDLE_HEADER): $(BUNDLE_GEN) $(RESOURCES)
	mkdir -p $(BUNDLE_INCLUDE_DIR)
	$(BUNDLE_GEN) . $(ASSETS_DIR) $(BUNDLE_HEADER)
	# force rebuild of the C bindings so it compiles with the new bundle.h
	rm -f $(RAYLEAN_DIR)/.lake/build/c/raylib_bindings.o
	rm -f $(RAYLEAN_DIR)/.lake/build/lib/librayliblean.a
	rm -f $(RAYLEAN_DIR)/.lake/build/lib/librayliblean.dylib

bundle: $(BUNDLE_HEADER)

raylib:
	$(MAKE) -f $(RAYLIB_MAKEFILE) \
		RAYLIB_BUILD_DIR=$(RAYLIB_BUILD_DIR) \
		MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) \
		NATIVE_COMPILER=$(LEAN_CC) build

build: raylib $(BUNDLE_HEADER)
	CPATH="$(CPATH)" \
	LIBRARY_PATH="$(LIBRARY_PATH)" \
	MACOSX_DEPLOYMENT_TARGET="$(MACOSX_DEPLOYMENT_TARGET)" \
	LEAN_CC="$(LEAN_CC)" \
	lake -R $(LAKE_ARGS) build

run: build
	lake $(LAKE_ARGS) exe flappy

clean:
	rm -rf $(BUNDLE_BUILD_DIR)
	$(MAKE) -f $(RAYLIB_MAKEFILE) clean
	lake $(LAKE_ARGS) clean
