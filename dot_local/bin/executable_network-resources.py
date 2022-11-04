#!/usr/bin/env python3

from seleniumwire import webdriver
from urllib.parse import urlparse
import argparse


def getDomain(s):
    return urlparse(s).netloc


def notHomePageInResource(homepage, res):
    return getDomain(homepage) not in getDomain(res)


def getNetworkResources(homepage):
    options = webdriver.FirefoxOptions()
    options.headless = True
    options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
        (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
    )
    driver = webdriver.Firefox(options=options)
    driver.implicitly_wait(20)
    resources = []

    driver.get(homepage)

    # https://support.mozilla.org/en-US/questions/1251590
    excluded_resource = ["firefox.com", "mozilla.com", "mozilla.net"]
    for request in driver.requests:
        if request.response:
            if not [e for e in excluded_resource if e in request.url]:
                resources.append(request.url)

    return set(resources)


def checkResources(homepage, resources):
    for res in resources:
        if notHomePageInResource(homepage, res):
            print(res)


def dumpResources(resources):
    for res in resources:
        print(res)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="network-resources",
        description="Verify resources that webpages will load",
    )
    parser.add_argument("url", action="store", nargs="+", help="URL(s) to check")
    parser.add_argument(
        "-c",
        "--check",
        action="store_true",
        help="List resources loaded from third party domains",
    )
    args = parser.parse_args()

    for u in args.url[1:]:
        r = getNetworkResources(u)
        if args.check:
            print(f"Checking {u}")
            checkResources(u, r)
            print(f"Finished with {u}\n")
        else:
            print(f"Dumping {u}")
            dumpResources(r)
            print(f"Finished with {u}\n")
