#!/usr/bin/env bash
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

set -e

docs_root=$(cd "$1" && pwd -P)
theme_temp_dir=$(mktemp -d)
trap 'rm -rf "$theme_temp_dir"' EXIT

# Hextra v0.13.0 ships compiled assets; no Go or Node build is required.
theme_commit=adf732f8d97cb8e149d4aba232a449d41cd9e38c
curl --fail --silent --show-error --location \
  "https://codeload.github.com/imfing/hextra/tar.gz/$theme_commit" \
  --output "$theme_temp_dir/hextra.tar.gz"
mkdir "$theme_temp_dir/hextra"
tar -xzf "$theme_temp_dir/hextra.tar.gz" --strip-components=1 -C "$theme_temp_dir/hextra"
flexsearch_version=0.8.143
curl --fail --silent --show-error --location \
  "https://cdn.jsdelivr.net/npm/flexsearch@$flexsearch_version/dist/flexsearch.bundle.min.js" \
  --output "$theme_temp_dir/flexsearch.bundle.min.js"
curl --fail --silent --show-error --location \
  "https://cdn.jsdelivr.net/npm/flexsearch@$flexsearch_version/LICENSE" \
  --output "$theme_temp_dir/flexsearch-LICENSE"

for site in document community blog; do
  if [ ! -d "$docs_root/$site" ]; then
    continue
  fi
  mkdir -p "$docs_root/$site/themes" "$docs_root/$site/assets/vendor" "$docs_root/$site/static/licenses"
  cp -R "$theme_temp_dir/hextra" "$docs_root/$site/themes/hextra"
  cp "$theme_temp_dir/flexsearch.bundle.min.js" "$docs_root/$site/assets/vendor/"
  cp "$theme_temp_dir/hextra/LICENSE" "$docs_root/$site/static/licenses/hextra.txt"
  cp "$theme_temp_dir/flexsearch-LICENSE" "$docs_root/$site/static/licenses/flexsearch.txt"
done
