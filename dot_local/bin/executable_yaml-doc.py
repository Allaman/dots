#!/usr/bin/env python3

import os
from pathlib import Path

found = False


def insertDocumentStart(path):
    p = Path(path)
    contents = p.read_text()
    contents = "---\n" + contents
    p.write_text(contents, encoding="utf8")
    return contents


def checkDocumentStart(path):
    global found
    with open(path, "r") as file:
        first_line = file.readline()
        if first_line != "---\n":
            print(f"Inserting document-start in '{path}'")
            found = True
            insertDocumentStart(path)


# Iterate over all yaml/yml files in the current directory
# Exclude all paths containing "special"
directory_name = "."
for subdir, dirs, filenames in os.walk(directory_name):
    # do not touch special folder
    if "special" in dirs:
        dirs.remove("special")
    for filename in filenames:
        path = subdir + os.sep + filename
        if not path.lower().endswith((".yaml", ".yml")):
            continue
        checkDocumentStart(path)

if found:
    print("Please add the changes to your commit")
    # Make pre commit hook fail
    os._exit(1)
