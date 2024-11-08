#!/usr/bin/env bash

SOURCE=$(gum input --placeholder "Source (leave empty for German)")
TARGET=$(gum input --placeholder "Target (leave empty for English)")
INPUT=$(gum input --placeholder "Text to translate")

[ -z "$SOURCE" ] && SOURCE=German
[ -z "$TARGET" ] && TARGET=English
[ -z "$INPUT" ] && {
  echo No text to translate
  exit 1
}

ENCODED_TEXT=$(echo "$INPUT" | gstring url encode)

open -a firefox "https://translate.kagi.com/?text=$ENCODED_TEXT&source=$SOURCE&target=$TARGET"
