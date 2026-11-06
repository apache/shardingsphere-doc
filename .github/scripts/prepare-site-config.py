#!/usr/bin/env python3
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

"""Build native navigation from published and staged documentation paths."""

import json
from pathlib import Path
import re
import sys
from urllib.parse import quote


def release_key(version):
  match = re.fullmatch(r"(\d+(?:\.\d+)*)(.*)", version)
  return tuple(map(int, match[1].split("."))), not match[2], match[2]


def menu_version(version):
  # Hugo lowercases menu paths; encoded letters preserve published case-sensitive tag directories.
  return "".join(f"%{ord(char):02x}" if "A" <= char <= "Z" else char for char in version)


def published_versions(published_root, history_root):
  document_root = published_root / "document"
  for version in json.loads((published_root / "versions.json").read_text()):
    if not (document_root / version).is_dir():
      sys.exit(f"Published documentation is missing: {document_root / version}")
  versions = {
    path.name: path for path in document_root.iterdir()
    if path.is_dir() and re.match(r"^\d+\.\d+", path.name)
  }
  if history_root:
    versions.update({
      path.name: path for path in history_root.iterdir()
      if path.is_dir() and re.match(r"^\d+\.\d+", path.name)
    })
  return {version: versions[version] for version in sorted(versions, key=release_key, reverse=True)}


def prepare_site(site, site_root, published_root, history_root, version):
  languages = {}
  versions = published_versions(published_root, history_root) if site == "document" else {}
  release_names = set(versions)
  if version != "current":
    release_names.add(version)
  version_names = ["current"] + sorted(release_names, key=release_key, reverse=True)
  # Hugo resolves menu URLs under baseURL; cancel its site prefix to keep public root paths.
  menu_prefix = "/../.." if site == "document" else "/.."
  for lang in ("en", "cn"):
    labels = ("Docs", "Community", "Blog", "Articles", "Videos") if lang == "en" else (
      "文档", "社区", "博客", "文章", "视频")
    menus = [
      {"name": labels[0], "url": f"{menu_prefix}/document/{menu_version(version)}/{lang}/overview/", "weight": 1},
      {"name": labels[1], "url": f"{menu_prefix}/community/{lang}/involved/", "weight": 2},
      {"name": labels[2], "url": f"{menu_prefix}/blog/{lang}/material/", "weight": 3},
    ]
    if site == "blog":
      menus.extend([
        {"name": labels[3], "url": f"{menu_prefix}/blog/{lang}/material/", "weight": 4},
        {"name": labels[4], "url": f"{menu_prefix}/blog/{lang}/videos/", "weight": 5},
      ])
    if site == "document":
      menus.append({"identifier": "versions", "name": version, "weight": 4})
      menus.extend({
        "parent": "versions", "name": name, "weight": index + 1,
        "url": f"{menu_prefix}/document/{menu_version(name)}/{lang}/overview/#doc-version",
      } for index, name in enumerate(version_names))
    menus.extend([
      {"identifier": "search", "name": "Search", "weight": 10, "params": {"type": "search", "icon": "search"}},
      {"name": "Language", "weight": 11, "params": {"type": "language-switch", "label": False}},
      {"name": "Theme", "weight": 12, "params": {"type": "theme-toggle"}},
    ])
    languages[lang] = {"menus": {"main": menus}}
  params = {"siteKind": site, "docsVersion": version}
  if version != "current":
    params["editURL"] = {"enable": False}
  config = {"languages": languages, "params": params}
  if site == "blog":
    cascade = [{"type": "blog", "target": {"kind": "{page,section,taxonomy,term}"}}]
    for path in (site_root / "content").rglob("*%*.md"):
      relative = path.relative_to(site_root / "content").as_posix()
      content_path = relative[:-3]
      lang = "en"
      for language in ("en", "cn"):
        if content_path.endswith("." + language):
          lang = language
          content_path = content_path[:-len(language) - 1]
          break
      # Native Hextra joins the unescaped filename into editURL; '%' is an invalid URL escape.
      cascade.append({
        "params": {"editURL": "https://github.com/apache/shardingsphere/edit/master/docs/blog/content/" + quote(relative, safe="/")},
        "target": {"path": "/" + content_path.lower().replace(" ", "-"),
                   "sites": {"matrix": {"languages": lang}}},
      })
    if len(cascade) > 1:
      config["cascade"] = cascade
  (site_root / "generated.json").write_text(json.dumps(config, ensure_ascii=False))
  if site == "document":
    versions["current"] = (history_root / "current" if history_root and (history_root / "current").is_dir()
                           else published_root / "document/current")
    pages = {
      name: {quote(path.parent.relative_to(root).as_posix() + "/", safe="/%"): True
             for path in root.rglob("index.html")}
      for name, root in versions.items()
    }
    (site_root / "data").mkdir(exist_ok=True)
    (site_root / "data/doc_versions.json").write_text(json.dumps({
      "versions": version_names, "pages": pages,
    }, separators=(",", ":")))


if sys.argv[1] == "versions":
  versions = published_versions(Path(sys.argv[2]), Path(sys.argv[3]) if sys.argv[3] else None)
  print(json.dumps(list(versions)))
else:
  prepare_site(sys.argv[2], Path(sys.argv[3]), Path(sys.argv[4]),
               Path(sys.argv[5]) if sys.argv[5] else None, sys.argv[6])
