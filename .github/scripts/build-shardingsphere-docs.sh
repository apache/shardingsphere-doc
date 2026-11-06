#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s <upstream-docs-root> <output-root>\n' "$0" >&2
  exit 1
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
renderer_root=$(cd "$script_dir/../website/shardingsphere" && pwd -P)
docs_root=$(cd "$1" && pwd -P)
output_parent=$(cd "$(dirname "$2")" && pwd -P)
output_root="$output_parent/$(basename "$2")"
case "$output_root/" in
  "$docs_root/"*|"$renderer_root/"*)
    printf 'Output must be outside the content and renderer sources: %s\n' "$output_root" >&2
    exit 1
    ;;
esac
if [ -e "$output_root" ] || [ -L "$output_root" ]; then
  printf 'Output must not already exist: %s\n' "$output_root" >&2
  exit 1
fi

build_temp_dir=$(mktemp -d)
trap 'rm -rf "$build_temp_dir"' EXIT
hugo_binary=${SHARDINGSPHERE_HUGO_BINARY:-hugo}
case "$("$hugo_binary" version)" in
  "hugo v0.169.0"*"+extended "*) ;;
  *) printf 'ShardingSphere requires Hugo 0.169.0 extended. Set SHARDINGSPHERE_HUGO_BINARY.\n' >&2; exit 1 ;;
esac
document_version=${SHARDINGSPHERE_DOCS_VERSION:-current}
versions_root=${SHARDINGSPHERE_DOCS_VERSIONS_ROOT:-"$script_dir/../.."}
history_root=${SHARDINGSPHERE_DOCS_HISTORY_ROOT:-}
sites=(document community blog)
if [ "${SHARDINGSPHERE_DOCS_SITES:-}" = document ]; then
  sites=(document)
fi

for site in "${sites[@]}"; do
  if [ ! -d "$docs_root/$site/content" ]; then
    printf 'Missing content directory: %s\n' "$docs_root/$site/content" >&2
    exit 1
  fi
  mkdir -p "$build_temp_dir/$site/static"
  cp -R "$docs_root/$site/content" "$build_temp_dir/$site/"
  if [ -d "$docs_root/$site/static" ]; then
    (
      cd "$docs_root/$site/static"
      tar --exclude='./css' --exclude='./js' --exclude='./fonts' --exclude='./webfonts' \
        -cf "$build_temp_dir/$site-static.tar" .
    )
    tar -xf "$build_temp_dir/$site-static.tar" -C "$build_temp_dir/$site/static"
  fi
  cp -R "$renderer_root/common/." "$build_temp_dir/$site/"
  cp -R "$renderer_root/$site/." "$build_temp_dir/$site/"
  python3 "$script_dir/prepare-site-config.py" site "$site" "$build_temp_dir/$site" \
    "$versions_root" "$history_root" "$document_version"
done

bash "$script_dir/prepare-hextra-theme.sh" "$build_temp_dir"
for site in "${sites[@]}"; do
  site_prefix="/$site"
  if [ "$site" = document ]; then
    site_prefix="/document/$document_version"
  fi
  (
    cd "$build_temp_dir/$site"
    "$hugo_binary" --config config.toml,generated.json \
      --baseURL "https://shardingsphere.apache.org$site_prefix/" --cleanDestinationDir
  )
  mkdir -p "$build_temp_dir/target$site_prefix"
  mv "$build_temp_dir/$site/public/"* "$build_temp_dir/target$site_prefix/"
done
mv "$build_temp_dir/target" "$output_root"
