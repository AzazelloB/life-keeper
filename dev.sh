#!/usr/bin/env sh

OUT_DIR="build/dev"

mkdir -p $OUT_DIR

odin run src --debug -out:$OUT_DIR/life-keeper -extra-linker-flags:"-L/opt/homebrew/lib"
