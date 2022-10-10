#!/bin/bash

# Create a favicon.ico from a SVG graphic

if [ $# -ne 1 ]; then
  echo "Missing argument"
  echo "Usage: $(basename $0) image.svg"
  exit 1
fi

command -v convert >/dev/null 2>&1 || { echo >&2 "require convert"; exit 1; }

convert "$1" -scale 16 /tmp/16.png
convert "$1" -scale 32 /tmp/32.png
convert "$1" -scale 48 /tmp/48.png
convert "$1" -scale 128 /tmp/128.png
convert "$1" -scale 256 /tmp/256.png

convert /tmp/16.png /tmp/32.png /tmp/48.png /tmp/128.png /tmp/256.png favicon.ico
