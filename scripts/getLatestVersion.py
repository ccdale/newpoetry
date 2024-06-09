#!/usr/bin/env python

import json
import requests
import sys

from ccaerrors import errorExit, errorNotify, errorRaise


def latestVersion(pkg):
    try:
        baseurl = "https://pypi.python.org/pypi"
        response = requests.get(f"{baseurl}/{pkg}/json")
        response.raise_for_status()
        return response.json()["info"]["version"]
    except Exception as e:
        errorRaise(sys.exc_info()[2], e)


def main():
    try:
        if len(sys.argv) == 2:
            print(latestVersion(sys.argv[1]))
    except Exception as e:
        errorExit(sys.exc_info()[2], e)


if __name__ == "__main__":
    main()
