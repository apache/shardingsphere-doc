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

docs_root=$(cd "$1" && pwd)
lock_file="$docs_root/themes.lock"
if [ ! -f "$lock_file" ]; then
  exit 0
fi

theme_temp_dir=$(mktemp -d)
trap 'rm -rf "$theme_temp_dir"' EXIT

while read -r site commit archive_sha256 || [ -n "$site" ]; do
  case "$site" in
    ""|\#*) continue ;;
  esac

  archive="$theme_temp_dir/$site.tar.gz"
  curl --fail --location --silent --show-error \
    "https://codeload.github.com/matcornic/hugo-theme-learn/tar.gz/$commit" \
    --output "$archive"
  if command -v sha256sum >/dev/null 2>&1; then
    checksum=$(sha256sum "$archive")
  else
    checksum=$(shasum -a 256 "$archive")
  fi
  if [ "${checksum%% *}" != "$archive_sha256" ]; then
    printf 'Learn theme checksum mismatch for %s\n' "$site" >&2
    exit 1
  fi

  extracted_theme="$theme_temp_dir/$site"
  mkdir "$extracted_theme"
  tar -xzf "$archive" --strip-components=1 -C "$extracted_theme"
  mkdir -p "$docs_root/$site/themes"
  rm -rf "$docs_root/$site/themes/hugo-theme-learn"
  mv "$extracted_theme" "$docs_root/$site/themes/hugo-theme-learn"
done < "$lock_file"
