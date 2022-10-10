#!/bin/bash

PDF_ENGINE=tectonic
INBOX=~/data/obsidian/articles/inbox
READING=~/data/obsidian/articles/reading
OUTBOX="$(mktemp -d)"

generate_pdf () {
  BASENAME=$(basename "$1" .md)
  pandoc "$1" --pdf-engine=$PDF_ENGINE -o "${OUTBOX}/${BASENAME}".pdf > /dev/null 2>&1
  mv "$1" $READING
}

send_pdf () {
  ~/.local/bin/pdf2remarkable.sh "$1"
}

clean_up () {
  echo "Cleaning up ..."
  rm -r $OUTBOX
}

for f in ${INBOX}/*.md
do
  echo "Generating $f"
  generate_pdf "$f"
done

for f in ${OUTBOX}/*.pdf
do
  send_pdf "$f"
done

ssh remarkable systemctl restart xochitl

trap clean_up EXIT
