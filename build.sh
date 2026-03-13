#!/usr/bin/env bash

set -e

BUILD_DIR="build"
OUTPUT_DIR="$BUILD_DIR/output"
VENDOR_DIR="$BUILD_DIR/vendor"

EXE_NAME="odin_sdl3_template"
SDL_VERSION="release-3.4.2"

mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$VENDOR_DIR"

clear

if [ "$1" = "build" ]; then
    odin build source -out:"$OUTPUT_DIR/$EXE_NAME"
elif [ "$1" = "build-debug" ]; then
    odin build source -out:"$OUTPUT_DIR/$EXE_NAME" -debug
elif [ "$1" = "run" ]; then
    odin run source -out:"$OUTPUT_DIR/$EXE_NAME"
elif [ "$1" = "run-debug" ]; then
    odin run source -out:"$OUTPUT_DIR/$EXE_NAME" -debug
elif [ "$1" = "build-sdl" ]; then
    cd "$VENDOR_DIR"

    if [ ! -d sdl ]; then
        [ -d sdl ] || git clone https://github.com/libsdl-org/SDL.git sdl
    fi

    cd sdl

    git checkout "$SDL_VERSION"
    cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    sudo cmake --install build
    sudo ldconfig
fi
