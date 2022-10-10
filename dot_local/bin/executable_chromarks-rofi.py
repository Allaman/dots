#!/usr/bin/env python3

# Read Chrome(ium) bookmarks database and use rofi to select a bookmark for further processing

import json
import sys
import argparse
from rofi import Rofi

parser = argparse.ArgumentParser(
    description="Parse chrome/chromium bookmarks file and choose a bookmark via rofi"
)
parser.add_argument(
    "path", metavar="PATH", type=str, nargs=None, help="Path to your bookmarks file"
)
parser.add_argument(
    "basefolder",
    metavar="BASE_FOLDER",
    type=str,
    nargs=None,
    help='Starting point to parse: "bookmark_bar" or "other"',
)
args = parser.parse_args()

with open(args.path) as f:
    data = json.load(f)

result = {}


def parse(elem):
    """
    Traverse the json structure and return a dictionary with the following structure:
    { Bookmark Name: Bookmark Url }
    """
    for obj in elem:
        if obj["type"] == "url":
            if obj["name"] in result:
                print(f"Error: duplicate {obj['name']} is overwritten!")
                sys.exit(1)
            # lower all names for rofi usability (case sensitive)
            result[obj["name"].lower()] = obj["url"]
        elif obj["type"] == "folder":
            parse(obj["children"])
        else:
            print(f"Unknown type {elem['type']}")
            sys.exit(1)
    return result


def rofi(data):
    """
    Start Rofi to select a bookmark and return ins URL
    """
    r = Rofi()
    urls = list(data.keys())
    # select requires a list and returs the index of the selected item
    url, key = r.select("Select Bookmark", urls)
    if key == -1:
        sys.exit(1)
    return data[urls[url]]


print(rofi(parse(data["roots"][args.basefolder]["children"])))
