import argparse, json, sys
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("infile", type=Path)
args = parser.parse_args()

# from jinja2.exceptions import AnsibleFilterError


def find_dictionary_key(candidates, d):
    for c in candidates:
        v = d.get(c, None)

        if v != None:
            return c, v

    return None, None


means = ["go", "cargo", "apt", "npm", "pipx"]

print(
    """#!/usr/bin/env bash

set -euxo pipefail
"""
)

with args.infile.open("r", encoding="utf-8") as f:
    parsed = json.load(f)

    for obj in parsed:
        k, package = find_dictionary_key(means, obj)

        if k is None:
            continue

        print(f"{k} {package} {obj}", file=sys.stderr)

        version = obj.get("version", None)

        if k == "apt":
            print(f"sudo apt-get install -qqy {package}")
        elif k == "go":
            print(f"go install {package}@{version}")
        elif k == "npm":
            if version is None:
                print(f"npm install -g {package}")
            else:
                print(f"npm install -g {package}@{version}")
        elif k == "pipx":
            if version is None:
                print(f"pipx install {package}")
            else:
                print(f"pipx install {package}=={version}")
        elif k == "cargo":
            if version is None or version is "":
                continue

            params = []

            if "git" in obj:
                params.extend(["--git", obj["git"]])
            else:
                params.extend(["--version", version])

            if "branch" in obj:
                params.extend(["--branch", obj["branch"]])

            if "features" in obj:
                params.extend(["--features", ",".join(obj["features"])])

            params_str = " ".join(params)
            print(f"cargo install {package} {params_str}")
