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
