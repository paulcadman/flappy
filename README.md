# Flappy Bird in Lean

This repo contains a clone of flappy bird implemented using [Lean](https://lean-lang.org/) and [Raylib](https://www.raylib.com).

https://github.com/user-attachments/assets/1a588542-be20-4f08-b17b-4b07a934c51d

## Building for macOS

1. Install Xcode command line tools

``` shell
xcode-select --install
```

2. Install dependencies

I recommend using [homebrew](https://brew.sh/).

``` shell
brew install gmp libuv sdl3 pkgconf resvg
```

3. Build the project

``` shell
make build
```

4. Run the game

``` shell
make run
```

Press SPACE to flap.

## Building for Linux

The project `Makefile` uses `pkg-config` to find dependencies, so it should work
if you have a C compiler installed and the dependencies listed in step 2. are
discoverable using `pkg-config`.

I have tested this with Arch linux, the `pkg-config` file was missing from the
`resvg` package so for the build to work you have to manually add the following
file:

`/usr/local/lib/pkgconfig/resvg.pc`
``` text
prefix=/usr
libdir=${prefix}/lib
includedir=${prefix}/include

Name: resvg
Description: SVG rendering library
Version: 0.47.0
Libs: -L${libdir} -lresvg
Cflags: -I${includedir}
```

If you get it to work with other Linux distros then let me know and I will
update this section.
