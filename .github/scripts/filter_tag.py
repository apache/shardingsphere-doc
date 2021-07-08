#!/bin/python3

from __future__ import print_function
import argparse
import os
from typing import List


def version_cmp(v: str):
    v0, v1, v2, *_ = v.split(".")
    sub_v = ""
    
    t = v2.split('-')
    if len(t) > 1:
        v2, sub_v = t
    else:
        t = v2.split(".")
        if len(t) > 1:
            v2, sub_v = t
        else:
            v2 = t[0]

    v2 = v2.split("-")[0].split(".")[0]
    v0, v1, v2 = int(v0.strip("v ")), int(v1.strip("v ")), int(v2.strip("v "))
    return [v0, v1, v2, 1 if len(sub_v) == 0 else 0]

def filter_tag():
    i = 0
    while i < len(tags):
        if i + 1 < len(tags):
            if tags[i+1].split("-")[0] == tags[i].split("-")[0] or tags[i+1][:-1] == tags[i][:-1]:
                del tags[i]
            else:
                i += 1
        else:
            i += 1
    tags.sort(key=version_cmp)
    if not remove_tag:
        for tag in tags:
            print(tag)
    else:
        for tag in copy_tags:
            if tag not in tags:
                print(tag)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--tags", type=str, nargs="*")
    parser.add_argument("--remove_tag", type=int, default=0)
    args = vars(parser.parse_args())
    tags: List[str] = args["tags"]
    import copy
    copy_tags = copy.deepcopy(tags)
    remove_tag: bool = args["remove_tag"]
    filter_tag()
